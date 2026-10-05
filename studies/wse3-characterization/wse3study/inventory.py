"""Deterministic, offline-first WSE-3 compiled-layout inventory.

The inventory deliberately distinguishes compiler output from facts recovered
only from CSL source.  A normal login shell can therefore freeze a campaign and
inspect already-built bundles without Singularity, ``cslc`` or ``cs_readelf``.
When a caller supplies a :class:`CsReadelfRunner`, the same code enriches the
native ELF observations with SDK-specific memory-bank output.

The SDK ELF files carry two particularly useful pieces of self-description:

* ``.pe_debug_info`` is JSON containing the compute filename and the resolved
  per-color router configuration.
* load-segment physical addresses carry the compiler fabric tile identifier.

Reading those structures directly avoids guessing coordinates from names such
as ``out_3_0.elf`` (those names are image identifiers, not reliable ``x,y``
coordinates).
"""

from __future__ import annotations

import ast
import hashlib
import json
import operator
import re
import shlex
import struct
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Iterable, Mapping, Protocol, Sequence

from .schema import (
    FABRIC_DIMS_WSE3,
    EvidenceKind,
    SCHEMA_VERSION,
    atomic_write_json,
    canonical_hash,
    evidence_record,
    hash_file,
    hash_tree,
    safe_name,
    validate_layout_contract,
)


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[3]
DEFAULT_SWEEP_SCRIPT = "run_full_template_sweep.sh"
DEFAULT_REGISTRY = "code_translation/cuda2csl.py"
PE_SRAM_BYTES = 48 * 1024

_CARDINAL_STEP = {
    "north": (0, -1),
    "south": (0, 1),
    "east": (1, 0),
    "west": (-1, 0),
}
_OPPOSITE = {
    "north": "south",
    "south": "north",
    "east": "west",
    "west": "east",
}
_SYSTEM_NAME_RE = re.compile(r"(?:^|[._])(?:sys_mod|MEMCPY|RXCOMMAND|RXACT)", re.I)
_ELF_NAME_RE = re.compile(r"out_(\d+)_(\d+)\.elf$")
_MEMORY_RE = re.compile(r"\((\d+),\s*(\d+)\):\s*(\d+)\s+bytes", re.I)
_SYMBOL_RE = re.compile(
    r"^\s*(?P<name>[^:\n]+):\s*addr=(?P<addr>0x[0-9a-f]+|\d+),"
    r"\s*size=(?P<size>\d+),\s*banks?=\[(?P<banks>[^]]*)\]",
    re.I | re.M,
)
_SDK_PATH_RE = re.compile(r"(?:rel-)?sdk[-_/](\d+\.\d+(?:\.\d+)?)", re.I)


class InventoryError(RuntimeError):
    """Raised when the canonical sweep or registry cannot be interpreted."""


class CsReadelfRunner(Protocol):
    """Injection point for an SDK-specific ``cs_readelf`` invocation.

    The inventory never invokes the SDK implicitly.  A runner must be supplied
    explicitly, which keeps offline inspection reproducible and makes tests
    independent of the ALCF service environment.
    """

    def run(self, elf_path: Path, flags: Sequence[str]) -> str:
        """Return stdout for ``cs_readelf FLAGS ELF_PATH`` or raise on failure."""


@dataclass(frozen=True)
class SubprocessCsReadelfRunner:
    """Opt-in runner suitable for an ALCF shell where the SDK wrapper works."""

    executable: str = "cs_readelf"
    timeout_seconds: int = 30

    def run(self, elf_path: Path, flags: Sequence[str]) -> str:
        result = subprocess.run(
            [self.executable, *flags, elf_path.name],
            cwd=elf_path.parent,
            check=False,
            capture_output=True,
            text=True,
            timeout=self.timeout_seconds,
        )
        if result.returncode:
            raise InventoryError(
                f"cs_readelf failed for {elf_path}: {result.stderr.strip()}"
            )
        return result.stdout


@dataclass(frozen=True)
class _Section:
    name: str
    section_type: int
    flags: int
    address: int
    offset: int
    size: int
    link: int
    entry_size: int


@dataclass(frozen=True)
class _ProgramHeader:
    segment_type: int
    flags: int
    offset: int
    virtual_address: int
    physical_address: int
    file_size: int
    memory_size: int


class _Elf64:
    """Small reader for the standard ELF structures used by SDK artifacts."""

    def __init__(self, path: Path):
        self.path = path
        self.data = path.read_bytes()
        if len(self.data) < 64 or self.data[:4] != b"\x7fELF":
            raise InventoryError(f"not an ELF file: {path}")
        if self.data[4] != 2 or self.data[5] != 1:
            raise InventoryError(f"unsupported ELF class/endianness: {path}")

        self._program_headers = self._read_program_headers()
        self._sections = self._read_sections()

    def _read_program_headers(self) -> tuple[_ProgramHeader, ...]:
        ph_offset = struct.unpack_from("<Q", self.data, 0x20)[0]
        ph_entry_size, ph_count = struct.unpack_from("<HH", self.data, 0x36)
        result: list[_ProgramHeader] = []
        for index in range(ph_count):
            offset = ph_offset + index * ph_entry_size
            if offset + 56 > len(self.data):
                raise InventoryError(f"truncated program-header table: {self.path}")
            values = struct.unpack_from("<IIQQQQQQ", self.data, offset)
            result.append(
                _ProgramHeader(
                    segment_type=values[0],
                    flags=values[1],
                    offset=values[2],
                    virtual_address=values[3],
                    physical_address=values[4],
                    file_size=values[5],
                    memory_size=values[6],
                )
            )
        return tuple(result)

    def _read_sections(self) -> tuple[_Section, ...]:
        sh_offset = struct.unpack_from("<Q", self.data, 0x28)[0]
        sh_entry_size, sh_count, names_index = struct.unpack_from(
            "<HHH", self.data, 0x3A
        )
        raw: list[tuple[int, ...]] = []
        for index in range(sh_count):
            offset = sh_offset + index * sh_entry_size
            if offset + 64 > len(self.data):
                raise InventoryError(f"truncated section-header table: {self.path}")
            raw.append(struct.unpack_from("<IIQQQQIIQQ", self.data, offset))
        if not raw:
            return ()
        if names_index >= len(raw):
            raise InventoryError(f"invalid section-name table: {self.path}")
        name_header = raw[names_index]
        names = self.data[name_header[4] : name_header[4] + name_header[5]]

        def section_name(index: int) -> str:
            if index >= len(names):
                return ""
            return names[index:].split(b"\0", 1)[0].decode("utf-8", "replace")

        return tuple(
            _Section(
                name=section_name(values[0]),
                section_type=values[1],
                flags=values[2],
                address=values[3],
                offset=values[4],
                size=values[5],
                link=values[6],
                entry_size=values[9],
            )
            for values in raw
        )

    @property
    def program_headers(self) -> tuple[_ProgramHeader, ...]:
        return self._program_headers

    @property
    def sections(self) -> tuple[_Section, ...]:
        return self._sections

    def section(self, name: str) -> _Section | None:
        return next((section for section in self.sections if section.name == name), None)

    def section_data(self, name: str) -> bytes | None:
        section = self.section(name)
        if section is None:
            return None
        end = section.offset + section.size
        if end > len(self.data):
            raise InventoryError(f"truncated {name} in {self.path}")
        return self.data[section.offset:end]

    def pe_debug_info(self) -> dict[str, Any] | None:
        raw = self.section_data(".pe_debug_info")
        if not raw:
            return None
        try:
            decoded = json.loads(raw.rstrip(b"\0").decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise InventoryError(f"invalid .pe_debug_info in {self.path}: {exc}") from exc
        return decoded if isinstance(decoded, dict) else None

    def program_tile_ids(self) -> list[int]:
        """Return tile IDs for code-image load segments.

        PE program images have a low-memory load starting at virtual address
        zero.  The fabric tile identifier occupies the high physical-address
        bits.  This is intentionally not derived from the ELF filename.
        """

        ids = {
            header.physical_address >> 40
            for header in self.program_headers
            if header.segment_type == 1
            and header.virtual_address == 0
            and header.memory_size >= 64
            and header.physical_address != 0
        }
        return sorted(ids)

    def all_tile_ids(self) -> list[int]:
        """Return tiles touched by any load segment (for route-only ELFs)."""

        return sorted(
            {
                header.physical_address >> 40
                for header in self.program_headers
                if header.segment_type == 1 and header.physical_address != 0
            }
        )

    def memory_summary(self) -> dict[str, Any]:
        low_memory_names = {
            ".data.lo",
            ".text",
            ".data",
            ".bss",
            ".task_table",
            ".data.hi",
        }
        sections = [
            section
            for section in self.sections
            if section.name in low_memory_names and section.address < 0xF000
        ]
        end = max((section.address + section.size for section in sections), default=0)
        return {
            "program_bytes": end,
            "program_bytes_evidence": EvidenceKind.COMPILED.value,
            "capacity_bytes": PE_SRAM_BYTES,
            "capacity_bytes_evidence": EvidenceKind.DOCUMENTED.value,
            "capacity_bytes_source": "WSE PE 48 KiB local SRAM architectural contract",
            "utilization": round(end / PE_SRAM_BYTES, 6) if end else 0.0,
            "utilization_evidence": EvidenceKind.INFERRED.value,
            "sections": {
                section.name: {
                    "address": section.address,
                    "bytes": section.size,
                }
                for section in sorted(sections, key=lambda item: (item.address, item.name))
            },
            "sections_evidence": EvidenceKind.COMPILED.value,
            "banks": None,
            "banks_evidence": EvidenceKind.INFERRED.value,
            "bank_status": "unknown_without_cs_readelf_sym",
        }

    def object_symbols(self, *, limit: int = 128) -> list[dict[str, Any]]:
        symtab = self.section(".symtab")
        if symtab is None or not symtab.entry_size or symtab.link >= len(self.sections):
            return []
        strings_section = self.sections[symtab.link]
        strings = self.data[
            strings_section.offset : strings_section.offset + strings_section.size
        ]
        symbols: list[dict[str, Any]] = []
        for offset in range(symtab.offset, symtab.offset + symtab.size, symtab.entry_size):
            if offset + 24 > len(self.data):
                break
            name_index, info, _other, section_index, value, size = struct.unpack_from(
                "<IBBHQQ", self.data, offset
            )
            symbol_type = info & 0xF
            if symbol_type != 1 or not size or name_index >= len(strings):
                continue
            name = strings[name_index:].split(b"\0", 1)[0].decode("utf-8", "replace")
            if not name:
                continue
            symbols.append(
                {
                    "name": name,
                    "address": value,
                    "bytes": size,
                    "section_index": section_index,
                    "banks": None,
                    "evidence": EvidenceKind.COMPILED.value,
                    "source": f"{self.path.name}:.symtab",
                }
            )
        symbols.sort(key=lambda item: (item["address"], item["name"]))
        return symbols[:limit]


def _strip_csl_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"//[^\n]*", "", text)


def _shell_without_comments(line: str) -> str:
    """Remove an unquoted shell comment without evaluating the shell."""

    quote: str | None = None
    escaped = False
    for index, char in enumerate(line):
        if escaped:
            escaped = False
            continue
        if char == "\\" and quote != "'":
            escaped = True
            continue
        if quote:
            if char == quote:
                quote = None
            continue
        if char in {"'", '"'}:
            quote = char
        elif char == "#":
            return line[:index]
    return line


def _logical_shell_lines(text: str) -> list[str]:
    result: list[str] = []
    buffer = ""
    for raw in text.splitlines():
        line = _shell_without_comments(raw).rstrip()
        if not line and not buffer:
            continue
        if line.endswith("\\"):
            buffer += line[:-1].strip() + " "
            continue
        logical = (buffer + line.strip()).strip()
        buffer = ""
        if logical:
            result.append(logical)
    if buffer.strip():
        result.append(buffer.strip())
    return result


def parse_compile_command(
    path: str | Path, command_index: int = 0
) -> dict[str, Any]:
    """Parse one active ``cslc`` command without executing shell code."""

    command_path = Path(path)
    logical_lines = _logical_shell_lines(command_path.read_text(encoding="utf-8"))
    candidates: list[tuple[str, list[str]]] = []
    for line in logical_lines:
        try:
            candidate = shlex.split(line)
        except ValueError:
            continue
        if any(Path(token).name == "cslc" for token in candidate):
            candidates.append((line, candidate))
    if not candidates:
        raise InventoryError(f"no cslc command found in {command_path}")
    try:
        command, tokens = candidates[command_index]
    except IndexError as exc:
        raise InventoryError(
            f"cslc command index {command_index} is out of range for {command_path} "
            f"({len(candidates)} command(s))"
        ) from exc

    cslc_index = next(
        index for index, token in enumerate(tokens) if Path(token).name == "cslc"
    )
    args = tokens[cslc_index + 1 :]

    def options(name: str) -> list[str]:
        values: list[str] = []
        index = 0
        while index < len(args):
            token = args[index]
            if token.startswith(name + "="):
                values.append(token.split("=", 1)[1])
            elif token == name and index + 1 < len(args):
                values.append(args[index + 1])
                index += 1
            index += 1
        return values

    def one(name: str) -> str | None:
        found = options(name)
        return found[-1] if found else None

    layout_token = next(
        (
            token
            for token in args
            if token.lower().endswith(".csl") and not token.startswith("--")
        ),
        None,
    )

    params: dict[str, str] = {}
    for value in options("--params"):
        for assignment in value.split(","):
            if ":" in assignment:
                key, raw_value = assignment.split(":", 1)
                params[key.strip()] = raw_value.strip()
    colors: dict[str, str] = {}
    for value in options("--colors"):
        for assignment in value.split(","):
            if ":" in assignment:
                key, raw_value = assignment.split(":", 1)
                colors[key.strip()] = raw_value.strip()

    def pair(value: str | None) -> dict[str, int] | None:
        if not value:
            return None
        pieces = value.split(",")
        if len(pieces) != 2:
            return None
        try:
            return {"x": int(pieces[0], 0), "y": int(pieces[1], 0)}
        except ValueError:
            return None

    output = one("-o") or one("--output")
    return {
        "command": command,
        "tokens": tokens,
        "layout": layout_token,
        "arch": one("--arch"),
        "fabric_dimensions": pair(one("--fabric-dims")),
        "fabric_offsets": pair(one("--fabric-offsets")),
        "params": params,
        "colors": colors,
        "output": output,
        "channels": _integer_or_string(one("--channels")),
        "memcpy": "--memcpy" in args,
        "width_west_buf": _integer_or_string(one("--width-west-buf")),
        "width_east_buf": _integer_or_string(one("--width-east-buf")),
    }


def parse_compile_commands(path: str | Path) -> list[dict[str, Any]]:
    """Parse every active compile variant in command-script order."""

    command_path = Path(path)
    count = 0
    for line in _logical_shell_lines(command_path.read_text(encoding="utf-8")):
        try:
            tokens = shlex.split(line)
        except ValueError:
            continue
        if any(Path(token).name == "cslc" for token in tokens):
            count += 1
    if not count:
        raise InventoryError(f"no cslc command found in {command_path}")
    return [parse_compile_command(command_path, index) for index in range(count)]


def _integer_or_string(value: str | None) -> int | str | None:
    if value is None:
        return None
    try:
        return int(value, 0)
    except ValueError:
        return value


_BINARY_OPERATORS: dict[type[ast.operator], Callable[[int, int], int]] = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.FloorDiv: operator.floordiv,
    ast.Div: operator.floordiv,
    ast.Mod: operator.mod,
    ast.LShift: operator.lshift,
    ast.RShift: operator.rshift,
    ast.BitOr: operator.or_,
    ast.BitAnd: operator.and_,
}


def _safe_int(expression: str, names: Mapping[str, int]) -> int | None:
    """Evaluate a small integer-only CSL expression."""

    expression = expression.strip()
    expression = re.sub(r"@(as|intCast)\([^,]+,\s*([^\)]+)\)", r"\2", expression)
    conditional = re.fullmatch(
        r"if\s*\((?P<condition>.*?)\)\s*(?P<yes>.*?)\s+else\s+(?P<no>.*)",
        expression,
        flags=re.S,
    )
    if conditional:
        expression = (
            f"({conditional.group('yes')}) if ({conditional.group('condition')}) "
            f"else ({conditional.group('no')})"
        )
    try:
        tree = ast.parse(expression, mode="eval")
    except SyntaxError:
        return None

    def visit(node: ast.AST) -> int | bool:
        if isinstance(node, ast.Expression):
            return visit(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, int):
            return node.value
        if isinstance(node, ast.Name) and node.id in names:
            return int(names[node.id])
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            value = visit(node.operand)
            return value if isinstance(node.op, ast.UAdd) else -value
        if isinstance(node, ast.BinOp) and type(node.op) in _BINARY_OPERATORS:
            return _BINARY_OPERATORS[type(node.op)](
                int(visit(node.left)), int(visit(node.right))
            )
        if isinstance(node, ast.IfExp):
            return visit(node.body if bool(visit(node.test)) else node.orelse)
        if isinstance(node, ast.BoolOp) and isinstance(node.op, (ast.And, ast.Or)):
            values = [bool(visit(value)) for value in node.values]
            return all(values) if isinstance(node.op, ast.And) else any(values)
        if isinstance(node, ast.Compare) and len(node.ops) == len(node.comparators):
            left = visit(node.left)
            comparisons = {
                ast.Eq: operator.eq,
                ast.NotEq: operator.ne,
                ast.Lt: operator.lt,
                ast.LtE: operator.le,
                ast.Gt: operator.gt,
                ast.GtE: operator.ge,
            }
            for operation, comparator in zip(node.ops, node.comparators):
                right = visit(comparator)
                function = comparisons.get(type(operation))
                if function is None or not function(left, right):
                    return False
                left = right
            return True
        raise ValueError

    try:
        value = visit(tree)
        return int(value)
    except (KeyError, TypeError, ValueError, ZeroDivisionError):
        return None


def _numeric_environment(source: str, params: Mapping[str, Any]) -> dict[str, int]:
    names: dict[str, int] = {}
    for key, value in params.items():
        parsed = _integer_or_string(str(value))
        if isinstance(parsed, int):
            names[key] = parsed

    clean = _strip_csl_comments(source)
    assignments = re.findall(
        r"\b(?:param|const)\s+([A-Za-z_]\w*)\s*(?::\s*[^=;]+)?=\s*([^;]+);",
        clean,
    )
    # Constants may depend on constants declared earlier or later.  Resolve to
    # a fixed point but never interpret function calls or other CSL syntax.
    for _ in range(len(assignments) + 1):
        changed = False
        for name, expression in assignments:
            if name in names:
                continue
            value = _safe_int(expression, names)
            if value is not None:
                names[name] = value
                changed = True
        if not changed:
            break
    return names


def parse_layout_source(path: str | Path, params: Mapping[str, Any]) -> dict[str, Any]:
    """Recover source-level rectangle and resource declarations conservatively."""

    layout_path = Path(path)
    source = layout_path.read_text(encoding="utf-8")
    clean = _strip_csl_comments(source)
    names = _numeric_environment(source, params)
    rectangle: dict[str, int] | None = None
    match = re.search(r"@set_rectangle\s*\(\s*([^,]+),\s*([^\)]+)\)", clean)
    if match:
        width = _safe_int(match.group(1), names)
        height = _safe_int(match.group(2), names)
        if width is not None and height is not None and width > 0 and height > 0:
            rectangle = {"width": width, "height": height}

    programs = sorted(set(re.findall(r"@set_tile_code\s*\([^;]*?\"([^\"]+\.csl)\"", clean, re.S)))
    exports = sorted(set(re.findall(r"@export_name\s*\(\s*\"([^\"]+)\"", clean)))
    colors = sorted(
        {
            value
            for expression in re.findall(r"@get_color\s*\(\s*([^\)]+)\)", clean)
            if (value := _safe_int(expression, names)) is not None
        }
    )

    return {
        "rectangle": rectangle,
        "program_candidates": programs,
        "exports": exports,
        "numeric_environment": dict(sorted(names.items())),
        "colors": colors,
    }


def _extract_registry(registry_path: Path, repo_root: Path) -> dict[str, dict[str, Any]]:
    source = registry_path.read_text(encoding="utf-8")
    tree = ast.parse(source, filename=str(registry_path))
    registry_node: ast.Dict | None = None
    for node in tree.body:
        if (
            isinstance(node, ast.Assign)
            and any(isinstance(target, ast.Name) and target.id == "KERNEL_REGISTRY" for target in node.targets)
            and isinstance(node.value, ast.Dict)
        ):
            registry_node = node.value
            break
    if registry_node is None:
        raise InventoryError(f"KERNEL_REGISTRY not found in {registry_path}")

    result: dict[str, dict[str, Any]] = {}
    for key_node, value_node in zip(registry_node.keys, registry_node.values):
        if not isinstance(key_node, ast.Constant) or not isinstance(key_node.value, str):
            continue
        name = key_node.value
        if (
            isinstance(value_node, ast.Call)
            and isinstance(value_node.func, ast.Name)
            and value_node.func.id == "_k"
            and len(value_node.args) >= 2
            and all(isinstance(arg, ast.Constant) and isinstance(arg.value, str) for arg in value_node.args[:2])
        ):
            benchmark_dir = str(value_node.args[0].value)
            target = str(value_node.args[1].value)
            result[name] = {
                "name": name,
                "benchmark_dir": f"kernels/{benchmark_dir}",
                "cuda_path": f"kernels/{benchmark_dir}/CUDA/kernel.cu",
                "csl_dir": f"kernels/{benchmark_dir}/CSL",
                "target_relpath": target,
                "commands_script": "commands_wse3.sh",
                "arch": "wse3",
            }
            continue

        # The only non-_k entry today is reference-only and not in the active
        # sweep.  Retain enough literal fields to report a future accidental
        # inclusion instead of silently dropping it.
        if isinstance(value_node, ast.Dict):
            literal: dict[str, Any] = {}
            for subkey, subvalue in zip(value_node.keys, value_node.values):
                if (
                    isinstance(subkey, ast.Constant)
                    and isinstance(subkey.value, str)
                    and isinstance(subvalue, ast.Constant)
                ):
                    literal[subkey.value] = subvalue.value
            if literal:
                literal["name"] = name
                result[name] = literal
    return result


def _extract_sweep(sweep_path: Path) -> list[dict[str, Any]]:
    active = False
    entries: list[dict[str, Any]] = []
    for raw_line in sweep_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not active:
            if re.match(r"KERNELS\s*=\s*\(", line):
                active = True
            continue
        if line == ")":
            break
        match = re.match(r'^"([^\"]+)"\s*(?:#.*)?$', line)
        if not match:
            continue
        fields = match.group(1).split("|")
        if len(fields) != 3:
            raise InventoryError(f"invalid sweep entry {match.group(1)!r} in {sweep_path}")
        name, reference, split = fields
        entries.append(
            {
                "name": name,
                "reference_cycles": int(reference) if reference.isdigit() else None,
                "split": split,
                "ordinal": len(entries),
            }
        )
    if not active or not entries:
        raise InventoryError(f"active KERNELS array not found in {sweep_path}")
    duplicates = sorted({item["name"] for item in entries if sum(e["name"] == item["name"] for e in entries) > 1})
    if duplicates:
        raise InventoryError(f"duplicate active kernels in {sweep_path}: {duplicates}")
    return entries


def discover_active_kernels(
    repo_root: str | Path = DEFAULT_REPO_ROOT,
    sweep_script: str | Path | None = None,
    registry_path: str | Path | None = None,
) -> list[dict[str, Any]]:
    """Discover the active suite by intersecting its canonical sweep and registry."""

    root = Path(repo_root).resolve()
    sweep = Path(sweep_script) if sweep_script else root / DEFAULT_SWEEP_SCRIPT
    registry_file = Path(registry_path) if registry_path else root / DEFAULT_REGISTRY
    if not sweep.is_absolute():
        sweep = root / sweep
    if not registry_file.is_absolute():
        registry_file = root / registry_file

    registry = _extract_registry(registry_file, root)
    active = _extract_sweep(sweep)
    result: list[dict[str, Any]] = []
    missing: list[str] = []
    for sweep_entry in active:
        entry = registry.get(sweep_entry["name"])
        if entry is None:
            missing.append(sweep_entry["name"])
            continue
        merged = dict(entry)
        merged["sweep"] = {
            "reference_cycles": sweep_entry["reference_cycles"],
            "split": sweep_entry["split"],
            "ordinal": sweep_entry["ordinal"],
        }
        result.append(merged)
    if missing:
        raise InventoryError(f"active kernels missing from registry: {', '.join(missing)}")
    return result


def _relative(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return str(path.resolve())


def _resolve_bundle_path(bundle: Path, raw: str | None, default: str) -> Path:
    candidate = bundle / (raw or default)
    resolved = candidate.resolve()
    try:
        resolved.relative_to(bundle.resolve())
    except ValueError as exc:
        raise InventoryError(f"artifact path escapes bundle: {candidate}") from exc
    return resolved


def _compiled_json(out_dir: Path) -> dict[str, Any]:
    path = out_dir / "out.json"
    if not path.is_file():
        return {}
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise InventoryError(f"invalid compiler out.json {path}: {exc}") from exc
    return value if isinstance(value, dict) else {}


def _compiled_rpc_symbols(out_dir: Path) -> list[dict[str, Any]]:
    path = out_dir / "bin" / "out_rpc.json"
    if not path.is_file():
        return []
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise InventoryError(f"invalid compiler RPC metadata {path}: {exc}") from exc
    symbols = value.get("rpc_symbols") if isinstance(value, dict) else None
    if not isinstance(symbols, list):
        return []
    return sorted(
        (dict(symbol) for symbol in symbols if isinstance(symbol, dict)),
        key=lambda symbol: (str(symbol.get("name", "")), str(symbol.get("kind", ""))),
    )


def _resource_inventory(bundle: Path, names: Mapping[str, int]) -> dict[str, Any]:
    task_ids: set[int] = set()
    input_queues: set[int] = set()
    output_queues: set[int] = set()
    microthreads: set[int] = set()
    colors: set[int] = set()
    source_files: list[str] = []
    patterns = {
        "task": re.compile(r"@get_(?:local|data)_task_id\s*\(\s*([^\)]+)\)"),
        "input": re.compile(r"@get_input_queue\s*\(\s*([^\)]+)\)"),
        "output": re.compile(r"@get_output_queue\s*\(\s*([^\)]+)\)"),
        "microthread": re.compile(
            r"@get_(?:microthread|microthread_id|ut_id)\s*\(\s*([^\)]+)\)"
        ),
        "color": re.compile(r"@get_color\s*\(\s*([^\)]+)\)"),
    }
    for path in sorted(bundle.rglob("*.csl")):
        if "out" in path.relative_to(bundle).parts:
            continue
        clean = _strip_csl_comments(path.read_text(encoding="utf-8", errors="replace"))
        found = False
        for kind, pattern in patterns.items():
            for expression in pattern.findall(clean):
                value = _safe_int(expression, names)
                if value is None:
                    continue
                found = True
                if kind == "task":
                    task_ids.add(value)
                elif kind == "input":
                    input_queues.add(value)
                elif kind == "output":
                    output_queues.add(value)
                elif kind == "microthread":
                    microthreads.add(value)
                else:
                    colors.add(value)
        if found:
            source_files.append(path.relative_to(bundle).as_posix())
    source = ",".join(source_files) if source_files else "no statically resolved declarations"
    return {
        "task_ids": evidence_record(sorted(task_ids), EvidenceKind.INFERRED, source=source),
        "input_queue_ids": evidence_record(sorted(input_queues), EvidenceKind.INFERRED, source=source),
        "output_queue_ids": evidence_record(sorted(output_queues), EvidenceKind.INFERRED, source=source),
        "microthread_ids": evidence_record(
            sorted(microthreads) if microthreads else None,
            EvidenceKind.INFERRED,
            source=source,
            uncertainty=(
                None
                if microthreads
                else "No explicit microthread IDs were statically resolvable; queue use does not prove a microthread mapping."
            ),
        ),
        "color_ids": evidence_record(sorted(colors), EvidenceKind.INFERRED, source=source),
    }


def _runner_output(
    runner: CsReadelfRunner | Callable[[Path, Sequence[str]], str] | None,
    elf_path: Path,
) -> tuple[str | None, str | None]:
    if runner is None:
        return None, None
    flags = ("--ms", "--sym", "--routing", "--switching", "--rect")
    try:
        if hasattr(runner, "run"):
            output = runner.run(elf_path, flags)  # type: ignore[union-attr]
        else:
            output = runner(elf_path, flags)  # type: ignore[operator]
        return str(output), None
    except Exception as exc:  # runner failure is enrichment failure, not data loss
        return None, str(exc)


def _parse_runner_enrichment(output: str | None) -> dict[str, Any]:
    if not output:
        return {}
    memory = {
        f"{match.group(1)},{match.group(2)}": int(match.group(3))
        for match in _MEMORY_RE.finditer(output)
    }
    symbols = []
    for match in _SYMBOL_RE.finditer(output):
        banks = [int(piece.strip()) for piece in match.group("banks").split(",") if piece.strip().isdigit()]
        symbols.append(
            {
                "name": match.group("name").strip(),
                "address": int(match.group("addr"), 0),
                "bytes": int(match.group("size")),
                "banks": banks,
                "evidence": EvidenceKind.COMPILED.value,
                "source": "cs_readelf --sym",
            }
        )
    symbols.sort(key=lambda item: (item["address"], item["name"]))
    return {
        "memory_bytes_by_coordinate": memory,
        "symbols": symbols,
        "stdout_sha256": hashlib.sha256(output.encode("utf-8")).hexdigest(),
    }


def _tile_to_coordinate(tile_id: int, fabric_width: int) -> dict[str, int]:
    return {"x": tile_id % fabric_width, "y": tile_id // fabric_width}


def _traffic_class(color_info: Mapping[str, Any], pe_role: str = "application") -> str:
    if pe_role != "application":
        return "system"
    names = [str(name) for name in color_info.get("known_names") or []]
    return "system" if any(_SYSTEM_NAME_RE.search(name) for name in names) else "application"


def _detected_sdk_versions(pes: Sequence[Mapping[str, Any]]) -> list[str]:
    """Recover SDK versions embedded in compiler-generated program paths.

    Older SDK ELFs do not serialize a toolchain version in ``out.json``.  Their
    generated memcpy programs commonly carry an absolute ``rel-sdk-X.Y.Z``
    source path in ``.pe_debug_info``.  This is useful compiled evidence, but
    absence of such a path remains unknown rather than being guessed.
    """

    versions: set[str] = set()
    for pe in pes:
        for candidate in (pe.get("program"), pe.get("source"), pe.get("artifact")):
            if candidate is None:
                continue
            versions.update(_SDK_PATH_RE.findall(str(candidate)))
    return sorted(versions, key=lambda value: tuple(int(piece) for piece in value.split(".")))


def _artifact_pe(
    elf_path: Path,
    *,
    role: str,
    fabric_width: int,
    offsets: Mapping[str, int] | None,
    repo_root: Path,
    runner: CsReadelfRunner | Callable[[Path, Sequence[str]], str] | None,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[str]]:
    parsed = _Elf64(elf_path)
    debug = parsed.pe_debug_info() or {}
    tile_ids = parsed.program_tile_ids()
    warnings: list[str] = []
    if len(tile_ids) != 1:
        warnings.append(
            f"{_relative(elf_path, repo_root)} has {len(tile_ids)} program tile IDs; coordinate left unresolved"
        )
        return [], [], warnings
    coordinate = _tile_to_coordinate(tile_ids[0], fabric_width)
    logical = None
    if role == "application" and offsets:
        logical = {
            "x": coordinate["x"] - int(offsets["x"]),
            "y": coordinate["y"] - int(offsets["y"]),
        }

    runner_output, runner_error = _runner_output(runner, elf_path)
    if runner_error:
        warnings.append(f"cs_readelf enrichment failed for {_relative(elf_path, repo_root)}: {runner_error}")
    enrichment = _parse_runner_enrichment(runner_output)
    memory = parsed.memory_summary()
    coordinate_key = f"{coordinate['x']},{coordinate['y']}"
    if coordinate_key in enrichment.get("memory_bytes_by_coordinate", {}):
        memory["program_bytes"] = enrichment["memory_bytes_by_coordinate"][coordinate_key]
        memory["utilization"] = round(memory["program_bytes"] / PE_SRAM_BYTES, 6)
        memory["source"] = "cs_readelf --ms"
    else:
        memory["source"] = f"{elf_path.name}:ELF low-memory sections"

    symbols = enrichment.get("symbols") or parsed.object_symbols()
    if enrichment.get("symbols"):
        memory["banks"] = sorted({bank for item in symbols for bank in item.get("banks", [])})
        memory["banks_evidence"] = EvidenceKind.COMPILED.value
        memory["bank_status"] = "reported_by_cs_readelf"

    artifact = _relative(elf_path, repo_root)
    pe = {
        "id": f"fabric:{coordinate['x']},{coordinate['y']}",
        "fabric": coordinate,
        "fabric_evidence": EvidenceKind.COMPILED.value,
        "logical": logical,
        "logical_evidence": EvidenceKind.INFERRED.value,
        "logical_source": (
            "compiled tile coordinate transformed by compiler-command fabric offsets"
            if logical is not None
            else "not applicable outside the application-local coordinate space"
        ),
        "role": role,
        "program": debug.get("filename"),
        "loaded": True,
        "configured": True,
        "memory": memory,
        "objects": symbols,
        "artifact": artifact,
        "artifact_sha256": hash_file(elf_path),
        "evidence": EvidenceKind.COMPILED.value,
        "source": f"{artifact}:PT_LOAD/.pe_debug_info/.symtab",
    }

    routes: list[dict[str, Any]] = []
    for color in debug.get("color_info") or []:
        if not isinstance(color, dict) or not isinstance(color.get("id"), int):
            continue
        routes.append(
            {
                "fabric": dict(coordinate),
                "logical": dict(logical) if logical else None,
                "pe_role": role,
                "color": color["id"],
                "rx": sorted(str(item).lower() for item in (color.get("rx") or [])),
                "tx": sorted(str(item).lower() for item in (color.get("tx") or [])),
                "switches": {
                    key: value
                    for key, value in sorted(color.items())
                    if key.startswith("pos")
                },
                "known_names": sorted(str(item) for item in (color.get("known_names") or [])),
                "traffic_class": _traffic_class(color, role),
                "traffic_class_evidence": EvidenceKind.INFERRED.value,
                "artifact": artifact,
                "evidence": EvidenceKind.COMPILED.value,
                "source": f"{artifact}:.pe_debug_info",
            }
        )
    return [pe], routes, warnings


def _route_only_pes(
    out_dir: Path, fabric_width: int, repo_root: Path, occupied: set[tuple[int, int]]
) -> tuple[list[dict[str, Any]], list[str]]:
    route_elf = out_dir / "generated" / "MEMCPY_XY_ROUTES.elf"
    if not route_elf.is_file():
        return [], []
    try:
        tile_ids = _Elf64(route_elf).all_tile_ids()
    except InventoryError as exc:
        return [], [str(exc)]
    records: list[dict[str, Any]] = []
    artifact = _relative(route_elf, repo_root)
    for tile_id in tile_ids:
        coordinate = _tile_to_coordinate(tile_id, fabric_width)
        key = (coordinate["x"], coordinate["y"])
        if key in occupied:
            continue
        records.append(
            {
                "id": f"fabric:{coordinate['x']},{coordinate['y']}",
                "fabric": coordinate,
                "fabric_evidence": EvidenceKind.COMPILED.value,
                "logical": None,
                "logical_evidence": EvidenceKind.INFERRED.value,
                "logical_source": "routing-only coordinates are outside the application-local space",
                "role": "routing-only",
                "program": None,
                "loaded": False,
                "configured": True,
                "memory": None,
                "objects": [],
                "artifact": artifact,
                "artifact_sha256": hash_file(route_elf),
                "evidence": EvidenceKind.COMPILED.value,
                "source": f"{artifact}:PT_LOAD p_paddr",
            }
        )
    return records, []


def _route_edges(
    routes: Sequence[Mapping[str, Any]],
    fabric_dimensions: Mapping[str, int],
) -> tuple[list[dict[str, Any]], list[str], list[str]]:
    configurations = {
        (
            int(route["fabric"]["x"]),
            int(route["fabric"]["y"]),
            int(route["color"]),
        ): route
        for route in routes
    }
    edges: list[dict[str, Any]] = []
    errors: list[str] = []
    warnings: list[str] = []
    width, height = fabric_dimensions["x"], fabric_dimensions["y"]
    for route in routes:
        x, y, color = (
            int(route["fabric"]["x"]),
            int(route["fabric"]["y"]),
            int(route["color"]),
        )
        if not 0 <= color < 24:
            errors.append(f"invalid WSE-3 color {color} at fabric ({x},{y})")
        for direction in route.get("tx") or []:
            direction = str(direction).lower()
            if direction == "ramp":
                edges.append(
                    {
                        "from": {"x": x, "y": y, "endpoint": "router"},
                        "to": {"x": x, "y": y, "endpoint": "ramp"},
                        "direction": "ramp",
                        "color": color,
                        "traffic_class": route["traffic_class"],
                        "traffic_class_evidence": route.get(
                            "traffic_class_evidence", EvidenceKind.INFERRED.value
                        ),
                        "destination_validation": "local",
                        "destination_validation_evidence": EvidenceKind.INFERRED.value,
                        "evidence": EvidenceKind.COMPILED.value,
                        "source": route["source"],
                    }
                )
                continue
            if direction not in _CARDINAL_STEP:
                errors.append(f"unknown route direction {direction!r} at fabric ({x},{y}) color {color}")
                continue
            dx, dy = _CARDINAL_STEP[direction]
            target = (x + dx, y + dy)
            if not (0 <= target[0] < width and 0 <= target[1] < height):
                errors.append(
                    f"route leaves fabric: ({x},{y}) --{direction}/c{color}--> ({target[0]},{target[1]})"
                )
                destination_validation = "out_of_bounds"
            else:
                target_config = configurations.get((target[0], target[1], color))
                if target_config is None:
                    destination_validation = "unobserved"
                elif _OPPOSITE[direction] in (target_config.get("rx") or []):
                    destination_validation = "matched"
                else:
                    destination_validation = "mismatch"
                    message = (
                        f"route destination mismatch: ({x},{y}) --{direction}/c{color}--> "
                        f"({target[0]},{target[1]})"
                    )
                    # A color may deliberately change router positions between
                    # phases.  The aggregate rx/tx fields alone do not prove an
                    # invalid compiled switch program, so retain the mismatch as
                    # a diagnostic warning rather than overclaiming an error.
                    warnings.append(message)
            edges.append(
                {
                    "from": {"x": x, "y": y, "endpoint": "router"},
                    "to": {"x": target[0], "y": target[1], "endpoint": "router"},
                    "direction": direction,
                    "color": color,
                    "traffic_class": route["traffic_class"],
                    "traffic_class_evidence": route.get(
                        "traffic_class_evidence", EvidenceKind.INFERRED.value
                    ),
                    "destination_validation": destination_validation,
                    "destination_validation_evidence": EvidenceKind.INFERRED.value,
                    "evidence": EvidenceKind.COMPILED.value,
                    "source": route["source"],
                }
            )
    edges.sort(
        key=lambda item: (
            item["from"]["y"],
            item["from"]["x"],
            item["color"],
            item["direction"],
        )
    )
    return edges, errors, warnings


def _artifact_hash(out_dir: Path) -> str | None:
    if not out_dir.is_dir():
        return None
    paths = sorted(
        path
        for path in out_dir.rglob("*")
        if path.is_file()
        and (
            path.suffix in {".json", ".elf"}
            or path.name == ".pe_debug_info"
        )
    )
    if not paths:
        return None
    digest = hashlib.sha256()
    for path in paths:
        digest.update(path.relative_to(out_dir).as_posix().encode("utf-8"))
        digest.update(b"\0")
        with path.open("rb") as handle:
            for block in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(block)
        digest.update(b"\0")
    return digest.hexdigest()


def _kernel_entry(
    kernel: str | Mapping[str, Any], repo_root: Path
) -> dict[str, Any]:
    if isinstance(kernel, str):
        matches = {
            entry["name"]: entry for entry in discover_active_kernels(repo_root)
        }
        try:
            return matches[kernel]
        except KeyError as exc:
            raise InventoryError(f"{kernel!r} is not in the active sweep") from exc
    return dict(kernel)


def build_kernel_inventory(
    kernel: str | Mapping[str, Any],
    repo_root: str | Path = DEFAULT_REPO_ROOT,
    *,
    compile_variant: int = 0,
    compile_variant_selection: Mapping[str, Any] | None = None,
    cs_readelf_runner: CsReadelfRunner
    | Callable[[Path, Sequence[str]], str]
    | None = None,
) -> dict[str, Any]:
    """Build one evidence-labelled layout dictionary.

    Missing output artifacts produce a useful, explicitly partial inventory;
    they never cause source-level guesses to be labelled ``compiled``.
    """

    root = Path(repo_root).resolve()
    entry = _kernel_entry(kernel, root)
    name = str(entry["name"])
    bundle = (root / str(entry["csl_dir"])).resolve()
    command_path = bundle / str(entry.get("commands_script", "commands_wse3.sh"))
    warnings: list[str] = []
    errors: list[str] = []
    unknowns: list[str] = []

    if not bundle.is_dir():
        raise InventoryError(f"CSL bundle not found for {name}: {bundle}")
    compile_variants = parse_compile_commands(command_path)
    try:
        compile_info = compile_variants[compile_variant]
    except IndexError as exc:
        raise InventoryError(
            f"compile variant {compile_variant} is out of range for {name} "
            f"({len(compile_variants)} variant(s))"
        ) from exc
    if compile_variant_selection is None:
        compile_variant_selection = {
            "index": compile_variant,
            "reason": "compile variant was selected explicitly by the inventory caller",
            "evidence": EvidenceKind.INFERRED.value,
            "source": "build_kernel_inventory(compile_variant=...)",
        }
    else:
        compile_variant_selection = dict(compile_variant_selection)
        if compile_variant_selection.get("index") != compile_variant:
            raise InventoryError(
                "compile variant selection contract does not match compile_variant"
            )
    layout_path = _resolve_bundle_path(bundle, compile_info.get("layout"), "layout.csl")
    if not layout_path.is_file():
        raise InventoryError(f"active layout not found for {name}: {layout_path}")
    out_dir = _resolve_bundle_path(bundle, compile_info.get("output"), "out")
    compiler_json = _compiled_json(out_dir)
    compiled_rpc_symbols = _compiled_rpc_symbols(out_dir)

    # Values serialized by the compiler override the command-line text.  A
    # disagreement is retained as a warning because it usually means stale out/.
    command_params = dict(compile_info["params"])
    compiled_params = {
        str(key): str(value) for key, value in (compiler_json.get("params") or {}).items()
    }
    for key in sorted(command_params.keys() & compiled_params.keys()):
        if command_params[key] != compiled_params[key]:
            warnings.append(
                f"stale-artifact candidate: command {key}={command_params[key]} but out.json has {compiled_params[key]}"
            )
    resolved_params = dict(command_params)
    resolved_params.update(compiled_params)
    layout_info = parse_layout_source(layout_path, resolved_params)

    dimensions = compile_info.get("fabric_dimensions")
    offsets = compile_info.get("fabric_offsets")
    if not dimensions:
        errors.append("compile command does not resolve --fabric-dims")
    if not offsets:
        warnings.append("compile command does not resolve --fabric-offsets; logical/fabric conversion is unavailable")
    rectangle = layout_info.get("rectangle")
    if rectangle is None:
        warnings.append("application rectangle is not statically resolvable")

    pes: list[dict[str, Any]] = []
    route_configs: list[dict[str, Any]] = []
    if dimensions:
        artifact_groups = (
            (out_dir / "bin", "application"),
            (out_dir / "west" / "bin", "io-west"),
            (out_dir / "east" / "bin", "io-east"),
        )
        for directory, role in artifact_groups:
            for elf_path in sorted(directory.glob("*.elf")) if directory.is_dir() else []:
                try:
                    new_pes, new_routes, new_warnings = _artifact_pe(
                        elf_path,
                        role=role,
                        fabric_width=dimensions["x"],
                        offsets=offsets,
                        repo_root=root,
                        runner=cs_readelf_runner,
                    )
                    pes.extend(new_pes)
                    route_configs.extend(new_routes)
                    warnings.extend(new_warnings)
                except (OSError, InventoryError) as exc:
                    errors.append(str(exc))

        occupied = {
            (int(pe["fabric"]["x"]), int(pe["fabric"]["y"])) for pe in pes
        }
        route_only, route_warnings = _route_only_pes(
            out_dir, dimensions["x"], root, occupied
        )
        pes.extend(route_only)
        warnings.extend(route_warnings)

    pes.sort(key=lambda pe: (pe["fabric"]["y"], pe["fabric"]["x"], pe["role"], pe["artifact"]))
    route_configs.sort(
        key=lambda route: (
            route["fabric"]["y"],
            route["fabric"]["x"],
            route["color"],
            route["pe_role"],
        )
    )

    # Validate compiled application coordinates against the layout contract.
    app_pes = [pe for pe in pes if pe["role"] == "application"]
    if app_pes and rectangle:
        for pe in app_pes:
            logical = pe.get("logical")
            if logical is None:
                continue
            if not (
                0 <= logical["x"] < rectangle["width"]
                and 0 <= logical["y"] < rectangle["height"]
            ):
                errors.append(
                    f"compiled application PE {pe['fabric']} maps outside logical rectangle {rectangle}"
                )
        expected = rectangle["width"] * rectangle["height"]
        unique_app = {
            (pe["fabric"]["x"], pe["fabric"]["y"]) for pe in app_pes
        }
        if len(unique_app) != expected:
            warnings.append(
                f"compiled application images cover {len(unique_app)} coordinates; rectangle allocates {expected}"
            )

    route_edges: list[dict[str, Any]] = []
    if dimensions:
        route_edges, route_errors, route_warnings = _route_edges(route_configs, dimensions)
        errors.extend(route_errors)
        warnings.extend(route_warnings)

    compiled_artifacts = bool(app_pes)
    rectangle_evidence = EvidenceKind.COMPILED if compiled_artifacts else EvidenceKind.INFERRED
    rectangle_source = (
        f"{_relative(layout_path, root)} plus compiled ELF coordinates"
        if compiled_artifacts
        else _relative(layout_path, root)
    )
    application_allocated = (
        rectangle["width"] * rectangle["height"] if rectangle else None
    )
    role_counts = {
        role: len({(pe["fabric"]["x"], pe["fabric"]["y"]) for pe in pes if pe["role"] == role})
        for role in ("application", "io-west", "io-east", "routing-only")
    }
    unique_loaded = {
        (pe["fabric"]["x"], pe["fabric"]["y"])
        for pe in pes
        if pe.get("loaded")
    }
    unique_configured = {
        (pe["fabric"]["x"], pe["fabric"]["y"])
        for pe in pes
        if pe.get("configured")
    }
    if not compiled_artifacts:
        unknowns.append("application loaded coordinates require compiled ELF artifacts")
    if len(compile_variants) > 1:
        unknowns.append(
            f"top-level layout represents compile variant {compile_variant}; inspect compile.variants and inventory each additional output separately"
        )
    unknowns.extend(
        [
            "dynamically active PEs require a timed simulator or silicon trace",
            "physical defect/spare remapping is not exposed by compiler artifacts",
        ]
    )

    numeric_names = layout_info.get("numeric_environment") or {}
    resources = _resource_inventory(bundle, numeric_names)
    sdk_versions = _detected_sdk_versions(pes)

    # Make the per-PE resource contract explicit.  Task/queue/microthread IDs
    # are a conservative bundle-wide static scan, so they must not be confused
    # with a compiler-resolved assignment for an individual PE.  Router colors
    # do come from that PE's compiled .pe_debug_info.
    colors_by_coordinate: dict[tuple[int, int], set[int]] = {}
    for route in route_configs:
        coordinate = route.get("fabric") or {}
        if not isinstance(coordinate, Mapping):
            continue
        key = (int(coordinate["x"]), int(coordinate["y"]))
        colors_by_coordinate.setdefault(key, set()).add(int(route["color"]))
    for pe in pes:
        coordinate = pe.get("fabric") or {}
        key = (int(coordinate["x"]), int(coordinate["y"]))
        pe["resources"] = {
            "colors": evidence_record(
                sorted(colors_by_coordinate.get(key, set())),
                EvidenceKind.COMPILED,
                source=f"{pe.get('artifact')}:.pe_debug_info",
            ),
            "task_ids": dict(resources["task_ids"]),
            "input_queue_ids": dict(resources["input_queue_ids"]),
            "output_queue_ids": dict(resources["output_queue_ids"]),
            "microthread_ids": dict(resources["microthread_ids"]),
            "assignment_scope": evidence_record(
                "bundle-wide static declarations",
                EvidenceKind.INFERRED,
                source=str(resources["task_ids"].get("source", "source scan")),
                uncertainty=(
                    "Task, queue, and microthread declarations were not resolved per PE; "
                    "only colors are tied to this compiled coordinate."
                ),
            ),
        }

    qualification_reasons: list[str] = []
    if not compiled_artifacts:
        qualification_reasons.append("no compiled application ELF coordinates")
    if str(compile_info.get("arch") or "").lower() != "wse3":
        qualification_reasons.append("compiler target is not wse3")
    if not dimensions or (dimensions["x"], dimensions["y"]) != FABRIC_DIMS_WSE3:
        qualification_reasons.append(
            "compiler allocation is not the ALCF full-fabric 762x1172 setting"
        )
    if not sdk_versions:
        qualification_reasons.append("compiled SDK version is unverified")
    elif not all(version.startswith("2.10") for version in sdk_versions):
        qualification_reasons.append(
            "retained compiler artifacts are not exclusively SDK 2.10.x"
        )
    if len(compile_variants) > 1:
        qualification_reasons.append(
            "the command bundle has multiple compile variants but this manifest covers only one"
        )
    acceptance_qualification = {
        "status": "qualified" if not qualification_reasons else "unqualified",
        "reasons": qualification_reasons,
        "evidence": EvidenceKind.INFERRED.value,
        "source": "study acceptance predicate over compiler artifacts and command metadata",
        "required_for_campaign_layout_acceptance": True,
    }
    params_record = {
        key: evidence_record(
            _integer_or_string(value),
            EvidenceKind.COMPILED if key in compiled_params else EvidenceKind.INFERRED,
            source=(
                _relative(out_dir / "out.json", root)
                if key in compiled_params
                else _relative(command_path, root)
            ),
        )
        for key, value in sorted(resolved_params.items())
    }

    generated_names = {
        child.name
        for child in bundle.iterdir()
        if child.is_dir() and child.name.startswith("out")
    }
    source_hash = hash_tree(
        bundle,
        exclude_names={
            ".git",
            "__pycache__",
            ".pytest_cache",
            "simfab_traces",
            *generated_names,
        },
    )
    artifact_hash = _artifact_hash(out_dir)
    inventory: dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "kind": "wse3-layout-inventory",
        "kernel": {
            "name": name,
            "benchmark_dir": entry.get("benchmark_dir"),
            "csl_dir": entry.get("csl_dir"),
            "cuda_path": entry.get("cuda_path"),
            "target_relpath": entry.get("target_relpath"),
            "sweep": entry.get("sweep"),
            "evidence": EvidenceKind.INFERRED.value,
            "source": f"{DEFAULT_SWEEP_SCRIPT} + {DEFAULT_REGISTRY}",
        },
        "compile": {
            "command": evidence_record(
                compile_info["command"], EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "layout_source": evidence_record(
                _relative(layout_path, root), EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "output_dir": evidence_record(
                _relative(out_dir, root), EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "arch": evidence_record(
                compile_info.get("arch"), EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "params": params_record,
            "colors": {
                key: evidence_record(
                    _integer_or_string(value), EvidenceKind.INFERRED, source=_relative(command_path, root)
                )
                for key, value in sorted(compile_info["colors"].items())
            },
            "memcpy": evidence_record(
                compile_info["memcpy"], EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "channels": evidence_record(
                compile_info["channels"], EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "width_west_buf": evidence_record(
                compile_info["width_west_buf"], EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "width_east_buf": evidence_record(
                compile_info["width_east_buf"], EvidenceKind.INFERRED, source=_relative(command_path, root)
            ),
            "toolchain": {
                "sdk_version": evidence_record(
                    None,
                    EvidenceKind.INFERRED,
                    source="not embedded in the retained compiler artifacts",
                    uncertainty="Capture the SDK version in the campaign compile manifest.",
                ),
                "client_version": evidence_record(
                    None,
                    EvidenceKind.INFERRED,
                    source="not embedded in the retained compiler artifacts",
                    uncertainty="Capture the appliance client version during execution preflight.",
                ),
                "detected_sdk_versions": evidence_record(
                    sdk_versions if sdk_versions else None,
                    EvidenceKind.COMPILED if sdk_versions else EvidenceKind.INFERRED,
                    source="compiler-generated program paths in .pe_debug_info",
                    uncertainty=(
                        None
                        if sdk_versions
                        else "No version-bearing compiler path was retained; this is not proof of any SDK version."
                    ),
                ),
            },
            "acceptance_qualification": acceptance_qualification,
            "selected_variant": compile_variant,
            "selected_variant_reason": compile_variant_selection.get("reason"),
            "selected_variant_selection": dict(compile_variant_selection),
            "variants": [
                {
                    "index": index,
                    "name": variant.get("output") or f"variant-{index}",
                    "command": evidence_record(
                        variant["command"],
                        EvidenceKind.INFERRED,
                        source=_relative(command_path, root),
                    ),
                    "layout": variant.get("layout"),
                    "output": variant.get("output"),
                    "arch": variant.get("arch"),
                    "fabric_dimensions": variant.get("fabric_dimensions"),
                    "fabric_offsets": variant.get("fabric_offsets"),
                    "params": dict(sorted(variant.get("params", {}).items())),
                    "colors": dict(sorted(variant.get("colors", {}).items())),
                    "evidence": EvidenceKind.INFERRED.value,
                    "source": _relative(command_path, root),
                }
                for index, variant in enumerate(compile_variants)
            ],
        },
        "fabric": {
            "system_dimensions": evidence_record(
                {"width": FABRIC_DIMS_WSE3[0], "height": FABRIC_DIMS_WSE3[1]},
                EvidenceKind.DOCUMENTED,
                source="ALCF WSE-3 compilation setting (--fabric-dims=762,1172)",
                uncertainty="Compiler fabric coordinates; hidden defect/spare remapping is excluded.",
            ),
            "dimensions": evidence_record(
                {"width": dimensions["x"], "height": dimensions["y"]} if dimensions else None,
                EvidenceKind.INFERRED,
                source=_relative(command_path, root),
                uncertainty="Compiler command input; use cs_readelf --rect to independently confirm." if dimensions else "Not resolved.",
            ),
            "allocation_dimensions": evidence_record(
                {"width": dimensions["x"], "height": dimensions["y"]} if dimensions else None,
                EvidenceKind.INFERRED,
                source=_relative(command_path, root),
                uncertainty="Exact command input, not proof that retained ELFs were built by the current campaign.",
            ),
            "offsets": evidence_record(
                offsets,
                EvidenceKind.INFERRED,
                source=_relative(command_path, root),
                uncertainty="Compiler command input; hidden silicon remapping is outside this coordinate system.",
            ),
        },
        "application": {
            "rectangle": evidence_record(
                rectangle,
                rectangle_evidence,
                source=rectangle_source,
                uncertainty=None if rectangle else "@set_rectangle expressions were not statically resolvable.",
            ),
            "program_candidates": evidence_record(
                layout_info.get("program_candidates") or [],
                EvidenceKind.INFERRED,
                source=_relative(layout_path, root),
            ),
            "exports": evidence_record(
                sorted(
                    str(symbol.get("name"))
                    for symbol in compiled_rpc_symbols
                    if symbol.get("name") is not None
                )
                if compiled_rpc_symbols
                else layout_info.get("exports") or [],
                EvidenceKind.COMPILED if compiled_rpc_symbols else EvidenceKind.INFERRED,
                source=(
                    _relative(out_dir / "bin" / "out_rpc.json", root)
                    if compiled_rpc_symbols
                    else _relative(layout_path, root)
                ),
            ),
            "rpc_symbols": evidence_record(
                compiled_rpc_symbols if compiled_rpc_symbols else None,
                EvidenceKind.COMPILED if compiled_rpc_symbols else EvidenceKind.INFERRED,
                source=_relative(out_dir / "bin" / "out_rpc.json", root),
                uncertainty=None if compiled_rpc_symbols else "Compiler RPC metadata is unavailable.",
            ),
        },
        "counts": {
            "application_allocated": evidence_record(
                application_allocated,
                rectangle_evidence,
                source=rectangle_source,
            ),
            "application_loaded": evidence_record(
                role_counts["application"] if compiled_artifacts else None,
                EvidenceKind.COMPILED if compiled_artifacts else EvidenceKind.INFERRED,
                source=_relative(out_dir, root),
                uncertainty=None if compiled_artifacts else "No compute ELF artifacts found.",
            ),
            "io_loaded": evidence_record(
                role_counts["io-west"] + role_counts["io-east"] if compiled_artifacts else None,
                EvidenceKind.COMPILED if compiled_artifacts else EvidenceKind.INFERRED,
                source=_relative(out_dir, root),
                uncertainty=None if compiled_artifacts else "No compiler output available.",
            ),
            "routing_only": evidence_record(
                role_counts["routing-only"] if compiled_artifacts else None,
                EvidenceKind.COMPILED if compiled_artifacts else EvidenceKind.INFERRED,
                source=_relative(out_dir / "generated" / "MEMCPY_XY_ROUTES.elf", root),
                uncertainty=None if compiled_artifacts else "No generated route ELF available.",
            ),
            "loaded_unique": evidence_record(
                len(unique_loaded) if compiled_artifacts else None,
                EvidenceKind.COMPILED if compiled_artifacts else EvidenceKind.INFERRED,
                source=_relative(out_dir, root),
                uncertainty=None if compiled_artifacts else "No compiler output available.",
            ),
            "configured_unique": evidence_record(
                len(unique_configured) if compiled_artifacts else None,
                EvidenceKind.COMPILED if compiled_artifacts else EvidenceKind.INFERRED,
                source=_relative(out_dir, root),
                uncertainty=None if compiled_artifacts else "No compiler output available.",
            ),
            "dynamically_active": evidence_record(
                None,
                EvidenceKind.INFERRED,
                source="not observable from static compiler artifacts",
                uncertainty="Requires events cropped to the device TSC window.",
            ),
        },
        "resources": resources,
        "pes": pes,
        "route_configs": route_configs,
        "route_edges": route_edges,
        "validation": {
            "status": "error" if errors else ("partial" if not compiled_artifacts else "ok"),
            "errors": sorted(set(errors)),
            "warnings": sorted(set(warnings)),
        },
        "unknowns": sorted(set(unknowns)),
        "acceptance_qualification": acceptance_qualification,
        "hashes": {
            "source_sha256": source_hash,
            "compile_command_sha256": canonical_hash(
                [variant["command"] for variant in compile_variants]
            ),
            "artifacts_sha256": artifact_hash,
        },
    }
    contract_errors = validate_layout_contract(inventory)
    if contract_errors:
        inventory["validation"]["errors"] = sorted(
            set(inventory["validation"]["errors"] + contract_errors)
        )
        inventory["validation"]["status"] = "error"
    inventory["hashes"]["inventory_sha256"] = canonical_hash(inventory)
    return inventory


def _active_compile_variant_selection(
    entry: Mapping[str, Any],
    repo_root: Path,
    *,
    sweep_script: str | Path | None = None,
    registry_path: str | Path | None = None,
) -> tuple[int, dict[str, Any]]:
    """Resolve the active compile variant without a positional default.

    A single-command bundle is unambiguous.  A multi-command bundle must have
    a source-audited relationship between the registry's active target and one
    compile parameter set.  The only such bundle in the current sweep is FFT:
    the registry targets ``ucode_2d.csl`` and ``layout.csl`` loads that program
    in the ``WIDTH > 1`` branch, where ``WIDTH`` is selected by ``DIM``.  This
    deliberately fails closed for any future multi-variant bundle until its
    relationship is made equally explicit.
    """

    bundle = (repo_root / str(entry.get("csl_dir") or "")).resolve()
    command_path = bundle / str(entry.get("commands_script") or "commands_wse3.sh")
    variants = parse_compile_commands(command_path)
    sweep_path = Path(sweep_script) if sweep_script else repo_root / DEFAULT_SWEEP_SCRIPT
    registry_file = Path(registry_path) if registry_path else repo_root / DEFAULT_REGISTRY
    if not sweep_path.is_absolute():
        sweep_path = repo_root / sweep_path
    if not registry_file.is_absolute():
        registry_file = repo_root / registry_file
    common_source = [
        _relative(sweep_path, repo_root),
        _relative(registry_file, repo_root),
        _relative(command_path, repo_root),
    ]
    if len(variants) == 1:
        return 0, {
            "index": 0,
            "reason": "the active bundle has exactly one compile command",
            "evidence": EvidenceKind.INFERRED.value,
            "source": common_source,
            "registry_target_relpath": entry.get("target_relpath"),
            "available_variant_count": 1,
        }

    target = Path(str(entry.get("target_relpath") or "")).name
    layout_names = {str(variant.get("layout") or "layout.csl") for variant in variants}
    if (
        entry.get("name") == "FFT-1D-2D"
        and target == "ucode_2d.csl"
        and len(layout_names) == 1
    ):
        layout_path = _resolve_bundle_path(bundle, next(iter(layout_names)), "layout.csl")
        clean = _strip_csl_comments(layout_path.read_text(encoding="utf-8"))
        width_contract = re.search(
            r"const\s+WIDTH\s*:[^=]+="
            r"\s*if\s*\(\s*DIM\s*==\s*1\s*\)\s*1\s*else\s*Nz\s*;",
            clean,
        )
        target_contract = re.search(
            r"if\s*\(\s*WIDTH\s*>\s*1\s*\)\s*\{.*?"
            r"@set_tile_code\s*\([^;]*[\"']ucode_2d\.csl[\"']",
            clean,
            flags=re.S,
        )
        fallback_contract = re.search(
            r"else\s*\{.*?@set_tile_code\s*\([^;]*"
            r"[\"']ucode_1d\.csl[\"']",
            clean,
            flags=re.S,
        )
        matching = [
            index
            for index, variant in enumerate(variants)
            if str((variant.get("params") or {}).get("DIM")) == "2"
        ]
        if width_contract and target_contract and fallback_contract and len(matching) == 1:
            index = matching[0]
            return index, {
                "index": index,
                "reason": (
                    "the active sweep registry targets ucode_2d.csl; layout.csl "
                    "loads it only in the WIDTH > 1 branch, and the unique DIM=2 "
                    "compile command is out-2D"
                ),
                "evidence": EvidenceKind.INFERRED.value,
                "source": common_source + [_relative(layout_path, repo_root)],
                "registry_target_relpath": entry.get("target_relpath"),
                "selection_parameter": {"DIM": "2"},
                "available_variant_count": len(variants),
                "unselected_variants_retained": [
                    index for index in range(len(variants)) if index not in matching
                ],
                "uncertainty": (
                    "commands_wse3.sh also retains upstream 1D validation commands; "
                    "that program is not the active registry translation target"
                ),
            }

    raise InventoryError(
        f"{entry.get('name')} has {len(variants)} compile variants but the active "
        "sweep/registry does not prove one source-level variant selection"
    )


def build_campaign_inventory(
    repo_root: str | Path = DEFAULT_REPO_ROOT,
    *,
    sweep_script: str | Path | None = None,
    registry_path: str | Path | None = None,
    cs_readelf_runner: CsReadelfRunner
    | Callable[[Path, Sequence[str]], str]
    | None = None,
    only: Iterable[str] | None = None,
) -> dict[str, Any]:
    """Freeze the active sweep and build deterministic per-kernel inventories."""

    root = Path(repo_root).resolve()
    entries = discover_active_kernels(root, sweep_script, registry_path)
    requested = set(only) if only is not None else None
    if requested is not None:
        available = {entry["name"] for entry in entries}
        missing = sorted(requested - available)
        if missing:
            raise InventoryError(f"requested kernels are not active: {', '.join(missing)}")
        entries = [entry for entry in entries if entry["name"] in requested]

    kernels: dict[str, Any] = {}
    errors: list[dict[str, str]] = []
    for entry in sorted(entries, key=lambda item: item["name"]):
        try:
            compile_variant, selection = _active_compile_variant_selection(
                entry,
                root,
                sweep_script=sweep_script,
                registry_path=registry_path,
            )
            kernels[entry["name"]] = build_kernel_inventory(
                entry,
                root,
                compile_variant=compile_variant,
                compile_variant_selection=selection,
                cs_readelf_runner=cs_readelf_runner,
            )
        except Exception as exc:
            errors.append({"kernel": entry["name"], "error": str(exc)})
            kernels[entry["name"]] = {
                "schema_version": SCHEMA_VERSION,
                "kind": "wse3-layout-inventory",
                "kernel": {"name": entry["name"]},
                "validation": {"status": "error", "errors": [str(exc)], "warnings": []},
            }

    statuses = [kernel.get("validation", {}).get("status") for kernel in kernels.values()]
    qualified = sum(
        (kernel.get("acceptance_qualification") or {}).get("status") == "qualified"
        for kernel in kernels.values()
    )
    parsed_compiled = statuses.count("ok")
    campaign: dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "kind": "wse3-characterization-campaign",
        "discovery": {
            "sweep_script": _relative(
                Path(sweep_script) if sweep_script else root / DEFAULT_SWEEP_SCRIPT, root
            ),
            "registry": _relative(
                Path(registry_path) if registry_path else root / DEFAULT_REGISTRY, root
            ),
            "active_kernel_names": [entry["name"] for entry in entries],
            "evidence": EvidenceKind.INFERRED.value,
        },
        "counts": {
            "discovered": len(entries),
            "parsed_compiled": parsed_compiled,
            "campaign_qualified": qualified,
            "complete": qualified,
            "partial": statuses.count("partial"),
            "error": statuses.count("error"),
        },
        "errors": errors,
        "kernels": kernels,
    }
    campaign["campaign_sha256"] = canonical_hash(campaign)
    return campaign


def write_inventory(
    campaign: Mapping[str, Any],
    output_root: str | Path,
    *,
    render_svgs: bool = True,
) -> dict[str, Any]:
    """Write ``campaign.json`` and each kernel's ``layout.json`` atomically."""

    output = Path(output_root)
    output.mkdir(parents=True, exist_ok=True)
    campaign_path = atomic_write_json(output / "campaign.json", campaign)
    kernel_paths: dict[str, dict[str, str]] = {}
    if render_svgs:
        from .svg import write_layout_svgs

    for name, layout in sorted((campaign.get("kernels") or {}).items()):
        directory = output / "kernels" / safe_name(str(name))
        layout_path = atomic_write_json(directory / "layout.json", layout)
        paths = {"layout": str(layout_path)}
        if render_svgs and layout.get("fabric"):
            paths.update(write_layout_svgs(layout, directory))
        kernel_paths[str(name)] = paths
    return {"campaign": str(campaign_path), "kernels": kernel_paths}


# Concise aliases used by callers that treat the subsystem as a builder.
inventory_kernel = build_kernel_inventory
inventory_campaign = build_campaign_inventory


__all__ = [
    "CsReadelfRunner",
    "InventoryError",
    "SubprocessCsReadelfRunner",
    "build_campaign_inventory",
    "build_kernel_inventory",
    "discover_active_kernels",
    "inventory_campaign",
    "inventory_kernel",
    "parse_compile_command",
    "parse_compile_commands",
    "parse_layout_source",
    "write_inventory",
]
