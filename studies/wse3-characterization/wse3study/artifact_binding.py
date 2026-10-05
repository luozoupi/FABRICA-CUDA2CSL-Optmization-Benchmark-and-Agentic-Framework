"""Safe binding of retained compiler archives to frozen campaign inputs.

The appliance compiler returns a ``tar.gz`` containing the exact uploaded CSL
tree, ``compile_command.sh``, ``out.json`` and the generated ELFs.  This module
decodes that archive without executing its shell script and without extracting
links or special files.  A layout is campaign-qualified only when the archive,
the runner-written compile record, the frozen suite request and the staged
source record form one exact cryptographic chain.

Older archives remain useful compiled evidence, but an archive with no current
compile record can never satisfy that chain by inference.
"""

from __future__ import annotations

import copy
import hashlib
import os
import shlex
import shutil
import tarfile
import tempfile
from pathlib import Path, PurePosixPath
from typing import Any, Callable, Mapping, Sequence

from .inventory import CsReadelfRunner, build_kernel_inventory
from .schema import (
    FABRIC_DIMS_WSE3,
    EvidenceKind,
    ValidationError,
    atomic_write_json,
    canonical_hash,
    evidence_record,
    hash_file,
    load_json,
    safe_name,
    utc_now,
    validate_layout_contract,
)


COMPILE_RECORD_SCHEMA_VERSION = "1.0.0"
_MAX_ARCHIVE_MEMBERS = 500_000
_MAX_ARCHIVE_BYTES = 8 * 1024 * 1024 * 1024
_SYNTHETIC_COMMAND = ".wse3study_bound_commands.sh"


def _safe_member_parts(name: str) -> tuple[str, ...]:
    if not name or "\\" in name:
        raise ValidationError(f"unsafe compiler archive member name: {name!r}")
    path = PurePosixPath(name)
    if path.is_absolute() or any(part in {"", ".", ".."} for part in path.parts):
        raise ValidationError(f"unsafe compiler archive member path: {name!r}")
    return path.parts


def _start_named_file(digest: Any, name: str) -> None:
    digest.update(name.encode("utf-8"))
    digest.update(b"\0")


def _finish_named_file(digest: Any) -> None:
    digest.update(b"\0")


def _parse_compiler_command(payload: bytes) -> dict[str, Any]:
    try:
        text = payload.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ValidationError("compile_command.sh is not UTF-8") from exc
    logical = [line.strip() for line in text.splitlines() if line.strip()]
    if len(logical) != 1:
        raise ValidationError("compile_command.sh must contain exactly one command")
    try:
        tokens = shlex.split(logical[0], posix=True)
    except ValueError as exc:
        raise ValidationError(f"invalid compile_command.sh quoting: {exc}") from exc
    if not tokens or Path(tokens[0]).name != "cslc":
        raise ValidationError("compile_command.sh does not contain one direct cslc command")
    if any(token in {";", "&&", "||", "|", "<", ">"} for token in tokens):
        raise ValidationError("shell control operators are forbidden in compile_command.sh")
    layouts = [token for token in tokens[1:] if token.lower().endswith(".csl")]
    if len(layouts) != 1:
        raise ValidationError("compile_command.sh must identify exactly one CSL main")
    layout = layouts[0]
    args = list(tokens[1:])
    args.remove(layout)
    return {
        "command": logical[0],
        "command_sha256": hashlib.sha256(payload).hexdigest(),
        "csl_main": layout,
        "compiler_args": shlex.join(args),
        "compiler_arg_tokens": args,
    }


def _option(tokens: Sequence[str], name: str) -> str | None:
    value: str | None = None
    index = 0
    while index < len(tokens):
        token = tokens[index]
        if token.startswith(name + "="):
            value = token.split("=", 1)[1]
        elif token == name and index + 1 < len(tokens):
            value = tokens[index + 1]
            index += 1
        index += 1
    return value


def _pair(value: str | None) -> list[int] | None:
    if value is None:
        return None
    pieces = value.split(",")
    if len(pieces) != 2:
        return None
    try:
        return [int(piece, 0) for piece in pieces]
    except ValueError:
        return None


def _assignments(value: str | None) -> dict[str, str]:
    result: dict[str, str] = {}
    for assignment in (value or "").split(","):
        if ":" in assignment:
            key, raw = assignment.split(":", 1)
            result[key.strip()] = raw.strip()
    return result


def effective_compile_contract(tokens: Sequence[str]) -> dict[str, Any]:
    """Return the scientific compiler contract represented by argument tokens."""

    return {
        "arch": _option(tokens, "--arch"),
        "fabric_dims": _pair(_option(tokens, "--fabric-dims")),
        "fabric_offsets": _pair(_option(tokens, "--fabric-offsets")),
        "params": _assignments(_option(tokens, "--params")),
        "colors": _assignments(_option(tokens, "--colors")),
        "memcpy": "--memcpy" in tokens,
        "channels": _option(tokens, "--channels"),
        "width_west_buf": _option(tokens, "--width-west-buf"),
        "width_east_buf": _option(tokens, "--width-east-buf"),
    }


def inspect_compiler_archive(path: str | os.PathLike[str]) -> dict[str, Any]:
    """Validate and describe one compiler archive without extracting it."""

    archive = Path(path)
    if archive.is_symlink() or not archive.is_file():
        raise ValidationError(f"compiler artifact is not a file: {archive}")
    artifact_sha256 = hash_file(archive)
    members: list[tarfile.TarInfo]
    try:
        with tarfile.open(archive, mode="r:*") as handle:
            members = handle.getmembers()
            if len(members) > _MAX_ARCHIVE_MEMBERS:
                raise ValidationError("compiler archive has too many members")
            seen: set[str] = set()
            roots: set[str] = set()
            total_bytes = 0
            command_payload: bytes | None = None
            has_elf = False
            csl_file_count = 0
            for member in members:
                parts = _safe_member_parts(member.name.rstrip("/"))
                normalized = "/".join(parts)
                if normalized in seen:
                    raise ValidationError(
                        f"duplicate compiler archive member: {normalized}"
                    )
                seen.add(normalized)
                roots.add(parts[0])
                if not (member.isdir() or member.isreg()):
                    raise ValidationError(
                        f"compiler archive contains a link or special file: {normalized}"
                    )
                if member.isdir():
                    continue
                total_bytes += int(member.size)
                if total_bytes > _MAX_ARCHIVE_BYTES:
                    raise ValidationError("compiler archive expands beyond the safety limit")
                relative = "/".join(parts[1:])
                if len(parts) >= 3 and parts[1] == "csl":
                    csl_file_count += 1
                if relative.startswith("out/") and relative.endswith(".elf"):
                    has_elf = True

            payload_digest = hashlib.sha256()
            csl_digest = hashlib.sha256()
            regular = sorted(
                (member for member in members if member.isreg()),
                key=lambda member: "/".join(
                    _safe_member_parts(member.name.rstrip("/"))[1:]
                ),
            )
            for member in regular:
                parts = _safe_member_parts(member.name.rstrip("/"))
                relative = "/".join(parts[1:])
                csl_relative = (
                    "/".join(parts[2:])
                    if len(parts) >= 3 and parts[1] == "csl"
                    else None
                )
                extracted = handle.extractfile(member)
                if extracted is None:
                    raise ValidationError(f"cannot read compiler archive member: {relative}")
                _start_named_file(payload_digest, relative)
                if csl_relative is not None:
                    _start_named_file(csl_digest, csl_relative)
                command_blocks: list[bytes] | None = (
                    [] if relative == "compile_command.sh" else None
                )
                bytes_read = 0
                for block in iter(lambda: extracted.read(1024 * 1024), b""):
                    bytes_read += len(block)
                    payload_digest.update(block)
                    if csl_relative is not None:
                        csl_digest.update(block)
                    if command_blocks is not None:
                        if bytes_read > 1024 * 1024:
                            raise ValidationError("compile_command.sh exceeds 1 MiB")
                        command_blocks.append(block)
                if bytes_read != member.size:
                    raise ValidationError(f"truncated compiler archive member: {relative}")
                _finish_named_file(payload_digest)
                if csl_relative is not None:
                    _finish_named_file(csl_digest)
                if command_blocks is not None:
                    command_payload = b"".join(command_blocks)
    except (tarfile.TarError, OSError) as exc:
        raise ValidationError(f"invalid compiler archive {archive}: {exc}") from exc

    if len(roots) != 1:
        raise ValidationError("compiler archive must have exactly one top-level directory")
    if command_payload is None:
        raise ValidationError("compiler archive has no compile_command.sh")
    if not csl_file_count:
        raise ValidationError("compiler archive has no uploaded CSL source tree")
    if not has_elf:
        raise ValidationError("compiler archive has no generated ELF")
    command = _parse_compiler_command(command_payload)
    return {
        "artifact_sha256": artifact_sha256,
        "artifact_bytes": archive.stat().st_size,
        "top_level": next(iter(roots)),
        "member_count": len(members),
        "expanded_bytes": total_bytes,
        "payload_tree_sha256": payload_digest.hexdigest(),
        "uploaded_csl_sha256": csl_digest.hexdigest(),
        **command,
        "contract": effective_compile_contract(command["compiler_arg_tokens"]),
    }


def extract_compiler_archive(
    path: str | os.PathLike[str], destination: str | os.PathLike[str]
) -> dict[str, Any]:
    """Extract regular files only, atomically, below an explicit destination."""

    archive = Path(path)
    target = Path(destination)
    if target.exists() or target.is_symlink():
        raise ValidationError(f"compiler artifact extraction already exists: {target}")
    description = inspect_compiler_archive(archive)
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=f".{target.name}.", dir=target.parent) as tmp:
        payload_root = Path(tmp) / "payload"
        payload_root.mkdir()
        with tarfile.open(archive, mode="r:*") as handle:
            for member in handle.getmembers():
                parts = _safe_member_parts(member.name.rstrip("/"))
                relative_parts = parts[1:]
                if not relative_parts:
                    continue
                output = payload_root.joinpath(*relative_parts)
                if member.isdir():
                    output.mkdir(parents=True, exist_ok=True)
                    continue
                output.parent.mkdir(parents=True, exist_ok=True)
                source = handle.extractfile(member)
                if source is None:
                    raise ValidationError(f"cannot extract compiler member {member.name}")
                with output.open("xb") as destination_handle:
                    shutil.copyfileobj(source, destination_handle)
        os.replace(payload_root, target)
    if hash_file(archive) != description["artifact_sha256"]:
        raise ValidationError("compiler archive changed while it was being extracted")
    return description


def _extracted_payload_sha256(root: Path) -> str:
    if root.is_symlink() or not root.is_dir():
        raise ValidationError(f"compiler extraction is not a real directory: {root}")
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            raise ValidationError(f"compiler extraction contains a link: {path}")
        if not path.is_file() or path.name == _SYNTHETIC_COMMAND:
            continue
        _start_named_file(digest, path.relative_to(root).as_posix())
        with path.open("rb") as handle:
            for block in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(block)
        _finish_named_file(digest)
    return digest.hexdigest()


def compile_record(
    *,
    request: Mapping[str, Any],
    compiler_archive: str | os.PathLike[str],
    artifact_original: str,
    compiler_args: str,
    csl_main: str,
    compiled_bundle_hash: str,
    compile_identity_hash: str,
    source_hash_verified: str,
    sdk_version: str | None,
    client_version: str | None,
    compile_variant_count: int,
    compile_variant_index: int,
    compile_variant_command_sha256: str,
) -> dict[str, Any]:
    """Create the exact sidecar required for later campaign qualification."""

    archive = Path(compiler_archive)
    description = inspect_compiler_archive(archive)
    contract = description["contract"]
    try:
        declared_tokens = shlex.split(compiler_args)
    except ValueError as exc:
        raise ValidationError(f"invalid effective compiler args: {exc}") from exc
    reasons: list[str] = []
    if declared_tokens != description["compiler_arg_tokens"]:
        reasons.append("retained compile_command.sh differs from effective compiler args")
    normalized_main = str(csl_main).removeprefix("./")
    archived_main = str(description["csl_main"]).removeprefix("./").removeprefix("csl/")
    if normalized_main != archived_main:
        reasons.append("retained compile_command.sh differs from the selected CSL main")
    expected_identity = canonical_hash(
        {
            "compiled_bundle_hash": compiled_bundle_hash,
            "csl_main": normalized_main,
            "compiler_args": compiler_args,
            "fabric_dims": contract.get("fabric_dims"),
            "arm": request.get("arm"),
            "sdk_version": sdk_version,
            "client_version": client_version,
            "variant": request.get("variant"),
            "variant_index": compile_variant_index,
        }
    )
    if compile_identity_hash != expected_identity:
        reasons.append("caller compile identity hash does not match exact compile fields")
    if reasons:
        raise ValidationError("; ".join(reasons))
    return {
        "compile_record_schema_version": COMPILE_RECORD_SCHEMA_VERSION,
        "request_key": request.get("request_key"),
        "subject": request.get("subject"),
        "kind": request.get("kind"),
        "arm": request.get("arm"),
        "variant": request.get("variant"),
        "telemetry_level": request.get("telemetry_level"),
        "source_hash": request.get("source_hash"),
        "source_hash_verified": source_hash_verified,
        "declared_compile_hash": request.get("compile_hash"),
        "compile_identity_hash": compile_identity_hash,
        "compiled_bundle_hash": compiled_bundle_hash,
        "compiler_args": compiler_args,
        "compiler_arg_tokens": declared_tokens,
        "csl_main": normalized_main,
        "architecture": contract.get("arch"),
        "fabric_dims": contract.get("fabric_dims"),
        "fabric_offsets": contract.get("fabric_offsets"),
        "sdk_version": sdk_version,
        "client_version": client_version,
        "compile_variant_count": compile_variant_count,
        "compile_variant_index": compile_variant_index,
        "compile_variant_command_sha256": compile_variant_command_sha256,
        "artifact_original": artifact_original,
        "artifact_preserved": str(archive),
        "artifact_sha256": description["artifact_sha256"],
        "artifact_bytes": description["artifact_bytes"],
        "artifact_member_count": description["member_count"],
        "artifact_expanded_bytes": description["expanded_bytes"],
        "artifact_payload_tree_sha256": description["payload_tree_sha256"],
        "uploaded_csl_sha256": description["uploaded_csl_sha256"],
        "compile_command_sha256": description["command_sha256"],
        "evidence": EvidenceKind.COMPILED.value,
        "recorded_at": utc_now(),
    }


def _record_value(record: Any) -> Any:
    if isinstance(record, Mapping) and "value" in record:
        return record.get("value")
    return record


def _expected_request(campaign_dir: Path, request_key: str) -> Mapping[str, Any] | None:
    suite = load_json(campaign_dir / "suite_requests.json")
    if not isinstance(suite, Mapping):
        return None
    matches = [
        request
        for request in suite.get("requests") or []
        if isinstance(request, Mapping) and request.get("request_key") == request_key
    ]
    return matches[0] if len(matches) == 1 else None


def _archive_next_to_record(record_path: Path, record: Mapping[str, Any]) -> Path:
    expected = str(record.get("artifact_sha256") or "")
    matches = [
        path
        for path in record_path.parent.iterdir()
        if path.is_file()
        and not path.is_symlink()
        and path.name != record_path.name
        and path.suffix != ".json"
        and expected
        and hash_file(path) == expected
    ]
    if len(matches) != 1:
        raise ValidationError(
            "compile record must have exactly one sibling artifact matching artifact_sha256"
        )
    return matches[0]


def _frozen_variant_count(layout: Mapping[str, Any]) -> int:
    variants = (layout.get("compile") or {}).get("variants") or []
    return len(variants) if isinstance(variants, list) else 0


def _rehash_layout(layout: dict[str, Any]) -> None:
    hashes = layout.setdefault("hashes", {})
    hashes.pop("inventory_sha256", None)
    hashes["inventory_sha256"] = canonical_hash(layout)


def _contract_reasons(
    frozen: Mapping[str, Any], archived: Mapping[str, Any]
) -> list[str]:
    reasons: list[str] = []
    compile_info = frozen.get("compile") or {}
    variants = compile_info.get("variants") or []
    if not isinstance(variants, list) or len(variants) != 1:
        return [
            "frozen kernel has multiple or missing compile variants; one artifact cannot be selected implicitly"
        ]
    expected = variants[0]
    contract = archived.get("contract") or {}
    comparisons = {
        "arch": str(expected.get("arch") or "").lower(),
        "params": {str(k): str(v) for k, v in (expected.get("params") or {}).items()},
        "colors": {str(k): str(v) for k, v in (expected.get("colors") or {}).items()},
    }
    actual = {
        "arch": str(contract.get("arch") or "").lower(),
        "params": {str(k): str(v) for k, v in (contract.get("params") or {}).items()},
        "colors": {str(k): str(v) for k, v in (contract.get("colors") or {}).items()},
    }
    for field in comparisons:
        if comparisons[field] != actual[field]:
            reasons.append(f"effective compiler {field} differs from the frozen variant")
    expected_offsets = expected.get("fabric_offsets")
    actual_offsets = contract.get("fabric_offsets")
    if isinstance(expected_offsets, Mapping):
        expected_offsets = [expected_offsets.get("x"), expected_offsets.get("y")]
    if expected_offsets != actual_offsets:
        reasons.append("effective fabric offsets differ from the frozen variant")
    for field in ("memcpy", "channels", "width_west_buf", "width_east_buf"):
        expected_value = _record_value(compile_info.get(field))
        actual_value = contract.get(field)
        if expected_value is not None and str(expected_value) != str(actual_value):
            reasons.append(f"effective compiler {field} differs from the frozen variant")
    expected_layout = str(expected.get("layout") or "").removeprefix("./")
    archived_layout = str(archived.get("csl_main") or "").removeprefix("./").removeprefix("csl/")
    if expected_layout and expected_layout != archived_layout:
        reasons.append("effective CSL main differs from the frozen variant")
    return reasons


def _build_bound_layout(
    *,
    frozen: Mapping[str, Any],
    record: Mapping[str, Any],
    request: Mapping[str, Any],
    archive: Path,
    record_path: Path,
    campaign_dir: Path,
    cs_readelf_runner: CsReadelfRunner
    | Callable[[Path, Sequence[str]], str]
    | None,
) -> dict[str, Any]:
    # ``frozen`` is the source/command inventory that existed before compiled
    # evidence was attached.  Binding must enrich that inventory, not erase its
    # identity.  In particular, run-suite uses the canonical source and frozen
    # compile seed to find an immutable SDK-2.10 stage.  If these values are
    # overwritten with the staged source or the newly retained compiler archive,
    # a subsequent plan ports an already-ported bundle and creates a different
    # scientific request.
    frozen_hashes = dict(frozen.get("hashes") or {})
    canonical_source_hash = str(
        frozen_hashes.get("canonical_source_sha256")
        or frozen_hashes.get("source_sha256")
        or ""
    )
    canonical_compile_command_hash = frozen_hashes.get(
        "canonical_compile_command_sha256",
        frozen_hashes.get("compile_command_sha256"),
    )
    canonical_artifacts_hash = frozen_hashes.get(
        "canonical_artifacts_sha256",
        frozen_hashes.get("artifacts_sha256"),
    )
    canonical_inventory_hash = frozen_hashes.get(
        "canonical_inventory_sha256",
        frozen_hashes.get("inventory_sha256"),
    )
    description = inspect_compiler_archive(archive)
    subject = str(record.get("subject") or "")
    extraction = (
        campaign_dir
        / "work"
        / "compiled-artifacts"
        / safe_name(subject)
        / str(record.get("arm") or "unknown")
        / description["artifact_sha256"][:16]
    )
    try:
        extraction.resolve(strict=False).relative_to(campaign_dir)
    except ValueError as exc:
        raise ValidationError("compiler extraction path escapes the campaign") from exc
    marker_path = extraction.parent / f"{extraction.name}.json"
    marker = load_json(marker_path)
    if extraction.exists():
        if (
            extraction.is_symlink()
            or marker_path.is_symlink()
            or not isinstance(marker, Mapping)
            or marker.get("artifact_sha256") != description["artifact_sha256"]
            or marker.get("payload_tree_sha256") != description["payload_tree_sha256"]
            or _extracted_payload_sha256(extraction)
            != description["payload_tree_sha256"]
        ):
            raise ValidationError(f"unattested existing compiler extraction: {extraction}")
    else:
        extract_compiler_archive(archive, extraction)
        if _extracted_payload_sha256(extraction) != description["payload_tree_sha256"]:
            raise ValidationError("extracted compiler payload does not match its archive")
        atomic_write_json(
            marker_path,
            {
                "artifact_sha256": description["artifact_sha256"],
                "payload_tree_sha256": description["payload_tree_sha256"],
                "source": str(archive),
            },
        )
    command_path = extraction / _SYNTHETIC_COMMAND
    command_path.write_text(description["command"] + "\n", encoding="utf-8")

    frozen_kernel = dict(frozen.get("kernel") or {})
    entry = {
        **frozen_kernel,
        "name": subject,
        "csl_dir": extraction.name,
        "commands_script": _SYNTHETIC_COMMAND,
    }
    layout = build_kernel_inventory(
        entry,
        extraction.parent,
        cs_readelf_runner=cs_readelf_runner,
    )
    layout["kernel"] = {
        **frozen_kernel,
        "name": subject,
        "compiled_artifact_bundle": str(extraction),
        "compiled_artifact_bundle_evidence": EvidenceKind.COMPILED.value,
    }

    reasons: list[str] = []
    if record.get("compile_record_schema_version") != COMPILE_RECORD_SCHEMA_VERSION:
        reasons.append("compile sidecar schema is absent or unsupported")
    if record.get("evidence") != EvidenceKind.COMPILED.value:
        reasons.append("compile sidecar is not labelled as compiled evidence")
    for field in (
        "request_key",
        "subject",
        "kind",
        "arm",
        "variant",
        "telemetry_level",
        "source_hash",
    ):
        if record.get(field) != request.get(field):
            reasons.append(f"compile sidecar {field} does not match the frozen suite request")
    if record.get("source_hash_verified") != request.get("source_hash"):
        reasons.append("compiled source hash was not verified against the frozen request")
    if record.get("declared_compile_hash") != request.get("compile_hash"):
        reasons.append("declared compile hash does not match the frozen request")
    if not record.get("compiled_bundle_hash"):
        reasons.append("compiled bundle hash is absent")
    if record.get("artifact_sha256") != description["artifact_sha256"]:
        reasons.append("retained artifact hash does not match the compile sidecar")
    if record.get("artifact_bytes") != description["artifact_bytes"]:
        reasons.append("retained artifact byte count does not match the compile sidecar")
    if record.get("artifact_member_count") != description["member_count"]:
        reasons.append("retained artifact member count does not match the compile sidecar")
    if record.get("artifact_expanded_bytes") != description["expanded_bytes"]:
        reasons.append("retained artifact expanded size does not match the compile sidecar")
    if record.get("artifact_payload_tree_sha256") != description["payload_tree_sha256"]:
        reasons.append("retained artifact payload differs from the compile sidecar")
    if record.get("uploaded_csl_sha256") != description["uploaded_csl_sha256"]:
        reasons.append("uploaded CSL source differs from the compile sidecar")
    if record.get("compile_command_sha256") != description["command_sha256"]:
        reasons.append("retained compile command differs from the compile sidecar")
    try:
        recorded_args = shlex.split(str(record.get("compiler_args") or ""))
    except ValueError:
        recorded_args = []
    if record.get("compiler_arg_tokens") != recorded_args:
        reasons.append("compile sidecar token vector does not match its compiler args")
    if recorded_args != description["compiler_arg_tokens"]:
        reasons.append("effective compiler args differ from the retained compile command")
    if str(record.get("csl_main") or "").removeprefix("./") != str(
        description["csl_main"]
    ).removeprefix("./").removeprefix("csl/"):
        reasons.append("selected CSL main differs from the retained compile command")
    if not str(record.get("sdk_version") or "").startswith("2.10."):
        reasons.append("exact compiler SDK version is absent or is not 2.10.x")
    if not str(record.get("client_version") or "").startswith("2.10."):
        reasons.append("exact appliance client version is absent or is not 2.10.x")
    if str(record.get("architecture") or "").lower() != "wse3":
        reasons.append("compile sidecar architecture is not wse3")
    if record.get("architecture") != (description.get("contract") or {}).get("arch"):
        reasons.append("compile sidecar architecture differs from the retained command")
    if record.get("fabric_dims") != list(FABRIC_DIMS_WSE3):
        reasons.append("compile sidecar does not attest the 762x1172 fabric")
    if record.get("fabric_offsets") != (description.get("contract") or {}).get(
        "fabric_offsets"
    ):
        reasons.append("compile sidecar fabric offsets differ from the retained command")
    if (description.get("contract") or {}).get("fabric_dims") != list(FABRIC_DIMS_WSE3):
        reasons.append("retained compile command does not use the 762x1172 fabric")
    expected_compile_identity = canonical_hash(
        {
            "compiled_bundle_hash": record.get("compiled_bundle_hash"),
            "csl_main": record.get("csl_main"),
            "compiler_args": record.get("compiler_args"),
            "fabric_dims": record.get("fabric_dims"),
            "arm": record.get("arm"),
            "sdk_version": record.get("sdk_version"),
            "client_version": record.get("client_version"),
            "variant": record.get("variant"),
            "variant_index": record.get("compile_variant_index"),
        }
    )
    if record.get("compile_identity_hash") != expected_compile_identity:
        reasons.append("compile identity hash does not match the exact sidecar fields")
    frozen_variant_count = _frozen_variant_count(frozen)
    if frozen_variant_count != 1:
        reasons.append(
            "multiple frozen compile variants require separately selected and bound artifacts"
        )
    if record.get("compile_variant_count") != frozen_variant_count:
        reasons.append("compile sidecar variant count differs from the frozen inventory")
    if record.get("compile_variant_index") != 0:
        reasons.append("compile sidecar does not explicitly select frozen variant zero")
    reasons.extend(_contract_reasons(frozen, description))

    stage_path = campaign_dir / "work" / "stages" / f"{safe_name(subject)}.json"
    stage = load_json(stage_path)
    if not isinstance(stage, Mapping):
        reasons.append("frozen stage manifest is missing")
    else:
        if stage.get("kernel") != subject:
            reasons.append("stage manifest kernel differs from the compile sidecar")
        if stage.get("canonical_source_hash") != canonical_source_hash:
            reasons.append("stage manifest does not bind the frozen canonical source hash")
        if stage.get("staged_source_hash") != request.get("source_hash"):
            reasons.append("stage manifest does not bind the compiled staged source hash")
        if stage.get("compile_variant_count") != 1 or stage.get(
            "compile_variant_index"
        ) != 0:
            reasons.append("stage manifest does not explicitly select one compile variant")
        if stage.get("staged_compile_command_sha256") != record.get(
            "compile_variant_command_sha256"
        ):
            reasons.append("compile sidecar does not bind the staged variant command")

    detected = _record_value(
        ((layout.get("compile") or {}).get("toolchain") or {}).get(
            "detected_sdk_versions"
        )
    )
    if detected and any(not str(version).startswith("2.10.") for version in detected):
        reasons.append("ELF debug metadata contradicts the SDK 2.10 compile sidecar")
    validation = layout.get("validation") or {}
    reasons.extend(str(reason) for reason in validation.get("errors") or [])
    reasons.extend(
        str(warning)
        for warning in validation.get("warnings") or []
        if str(warning).startswith("stale-artifact candidate:")
    )

    binding = {
        "status": "qualified" if not reasons else "unqualified",
        "reasons": sorted(set(reasons)),
        "compile_record": str(record_path),
        "compile_record_sha256": hash_file(record_path),
        "artifact": str(archive),
        "artifact_sha256": description["artifact_sha256"],
        "uploaded_csl_sha256": description["uploaded_csl_sha256"],
        "request_key": record.get("request_key"),
        "variant": record.get("variant"),
        "variant_index": record.get("compile_variant_index"),
        "sdk_version": record.get("sdk_version"),
        "effective_compiler_args": record.get("compiler_args"),
        "fabric_dims": record.get("fabric_dims"),
        "evidence": EvidenceKind.COMPILED.value,
    }
    layout.setdefault("compile", {})["artifact_binding"] = binding
    layout["compile"]["command"] = evidence_record(
        description["command"],
        EvidenceKind.COMPILED,
        source=f"{archive}:compile_command.sh",
    )
    layout["compile"]["toolchain"]["sdk_version"] = evidence_record(
        record.get("sdk_version"),
        EvidenceKind.COMPILED,
        source=str(record_path),
    )
    layout["compile"]["toolchain"]["client_version"] = evidence_record(
        record.get("client_version"),
        EvidenceKind.COMPILED,
        source=str(record_path),
    )
    recorded_dims = record.get("fabric_dims")
    if not isinstance(recorded_dims, list) or len(recorded_dims) != 2:
        recorded_dims = [None, None]
    layout["fabric"]["dimensions"] = evidence_record(
        {"width": recorded_dims[0], "height": recorded_dims[1]},
        EvidenceKind.COMPILED,
        source=f"{archive}:compile_command.sh + {record_path}",
    )
    layout["fabric"]["allocation_dimensions"] = copy.deepcopy(
        layout["fabric"]["dimensions"]
    )
    layout["acceptance_qualification"] = {
        "status": binding["status"],
        "reasons": binding["reasons"],
        "evidence": EvidenceKind.COMPILED.value,
        "source": "retained artifact + exact compile sidecar + frozen request/stage predicate",
        "required_for_campaign_layout_acceptance": True,
    }
    layout["compile"]["acceptance_qualification"] = copy.deepcopy(
        layout["acceptance_qualification"]
    )
    layout["hashes"].update(
        {
            "canonical_source_sha256": canonical_source_hash,
            "canonical_compile_command_sha256": canonical_compile_command_hash,
            "canonical_artifacts_sha256": canonical_artifacts_hash,
            "canonical_inventory_sha256": canonical_inventory_hash,
            "source_sha256": request.get("source_hash"),
            "compiled_bundle_sha256": record.get("compiled_bundle_hash"),
            "uploaded_csl_sha256": description["uploaded_csl_sha256"],
            "compile_command_sha256": description["command_sha256"],
            "compile_identity_sha256": record.get("compile_identity_hash"),
            "artifacts_sha256": description["artifact_sha256"],
        }
    )
    contract_errors = validate_layout_contract(layout)
    if contract_errors:
        layout["validation"]["errors"] = sorted(
            set((layout["validation"].get("errors") or []) + contract_errors)
        )
        layout["validation"]["status"] = "error"
        layout["acceptance_qualification"]["status"] = "unqualified"
        layout["acceptance_qualification"]["reasons"] = sorted(
            set(layout["acceptance_qualification"]["reasons"] + contract_errors)
        )
        layout["compile"]["artifact_binding"]["status"] = "unqualified"
        layout["compile"]["artifact_binding"]["reasons"] = layout[
            "acceptance_qualification"
        ]["reasons"]
    _rehash_layout(layout)
    return layout


def bind_campaign_compile_artifacts(
    campaign: Mapping[str, Any],
    campaign_dir: str | os.PathLike[str],
    *,
    artifact_root: str | os.PathLike[str] | None = None,
    cs_readelf_runner: CsReadelfRunner
    | Callable[[Path, Sequence[str]], str]
    | None = None,
) -> dict[str, Any]:
    """Return a campaign copy enriched by safely bound retained artifacts."""

    root = Path(campaign_dir).resolve()
    store = Path(artifact_root).resolve() if artifact_root else root / "artifacts"
    result = copy.deepcopy(dict(campaign))
    kernels = result.get("kernels") or {}
    summaries: list[dict[str, Any]] = []
    candidates: dict[str, list[dict[str, Any]]] = {}
    ignored_non_suite = 0
    record_paths = sorted(store.rglob("compile.json")) if store.is_dir() else []
    for record_path in record_paths:
        if record_path.is_symlink():
            summaries.append(
                {
                    "status": "unqualified",
                    "subject": None,
                    "compile_record": str(record_path),
                    "reasons": ["compile record is a symbolic link"],
                }
            )
            continue
        record = load_json(record_path)
        subject = str(record.get("subject") or "") if isinstance(record, Mapping) else ""
        if isinstance(record, Mapping) and record.get("kind") not in {None, "suite"}:
            ignored_non_suite += 1
            continue
        if not isinstance(record, Mapping) or subject not in kernels:
            summaries.append(
                {
                    "status": "unqualified",
                    "subject": subject or None,
                    "compile_record": str(record_path),
                    "reasons": ["compile record is invalid or its subject is not frozen"],
                }
            )
            continue
        request = _expected_request(root, str(record.get("request_key") or ""))
        if request is None:
            summaries.append(
                {
                    "status": "unqualified",
                    "subject": subject,
                    "compile_record": str(record_path),
                    "reasons": ["no unique frozen suite request matches request_key"],
                }
            )
            continue
        try:
            archive = _archive_next_to_record(record_path, record)
            layout = _build_bound_layout(
                frozen=kernels[subject],
                record=record,
                request=request,
                archive=archive,
                record_path=record_path,
                campaign_dir=root,
                cs_readelf_runner=cs_readelf_runner,
            )
            directory = root / "kernels" / safe_name(subject) / "compiled-layouts"
            candidate_path = atomic_write_json(
                directory
                / f"{safe_name(str(record.get('arm') or 'unknown'))}-{str(record.get('request_key'))[:16]}.json",
                layout,
            )
            summary = {
                "status": layout["acceptance_qualification"]["status"],
                "subject": subject,
                "arm": record.get("arm"),
                "variant": record.get("variant"),
                "request_key": record.get("request_key"),
                "compile_record": str(record_path),
                "layout": str(candidate_path),
                "reasons": layout["acceptance_qualification"]["reasons"],
            }
            candidates.setdefault(subject, []).append(
                {"layout": layout, "summary": summary}
            )
            summaries.append(summary)
        except (OSError, ValidationError, tarfile.TarError) as exc:
            summaries.append(
                {
                    "status": "unqualified",
                    "subject": subject,
                    "compile_record": str(record_path),
                    "reasons": [f"{type(exc).__name__}: {exc}"],
                }
            )

    for subject, frozen in kernels.items():
        subject_candidates = candidates.get(str(subject), [])
        qualified = [
            candidate
            for candidate in subject_candidates
            if candidate["layout"]["acceptance_qualification"]["status"] == "qualified"
        ]
        binding_summaries = [candidate["summary"] for candidate in subject_candidates]
        if len(qualified) == 1:
            selected = qualified[0]["layout"]
            selected["compiled_artifact_bindings"] = binding_summaries
            _rehash_layout(selected)
            kernels[subject] = selected
        else:
            frozen["compiled_artifact_bindings"] = binding_summaries
            if len(qualified) > 1:
                frozen["acceptance_qualification"] = {
                    "status": "unqualified",
                    "reasons": [
                        "multiple campaign-qualified compiler artifacts match this kernel; selection is ambiguous"
                    ],
                    "evidence": EvidenceKind.INFERRED.value,
                    "source": "retained compiler artifact selection predicate",
                    "required_for_campaign_layout_acceptance": True,
                }
            _rehash_layout(frozen)

    qualified_count = sum(
        (layout.get("acceptance_qualification") or {}).get("status") == "qualified"
        for layout in kernels.values()
    )
    result.setdefault("counts", {})["campaign_qualified"] = qualified_count
    result["counts"]["complete"] = qualified_count
    result["artifact_binding"] = {
        "schema_version": COMPILE_RECORD_SCHEMA_VERSION,
        "artifact_root": str(store),
        "records_scanned": len(record_paths),
        "non_suite_records_ignored": ignored_non_suite,
        "qualified_kernels": qualified_count,
        "summaries": summaries,
        "evidence": EvidenceKind.INFERRED.value,
    }
    result.pop("campaign_sha256", None)
    result["campaign_sha256"] = canonical_hash(result)
    return result


__all__ = [
    "COMPILE_RECORD_SCHEMA_VERSION",
    "bind_campaign_compile_artifacts",
    "compile_record",
    "effective_compile_contract",
    "extract_compiler_archive",
    "inspect_compiler_archive",
]
