from __future__ import annotations

import copy
import io
import json
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


STUDY_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(STUDY_ROOT))

from wse3study.artifact_binding import (  # noqa: E402
    bind_campaign_compile_artifacts,
    compile_record,
    extract_compiler_archive,
    inspect_compiler_archive,
)
from wse3study.schema import (  # noqa: E402
    EvidenceKind,
    LAYOUT_COUNT_FIELDS,
    ValidationError,
    atomic_write_json,
    canonical_hash,
    evidence_record,
)


FROZEN_COMMAND = (
    "cslc ./layout.csl --arch=wse3 --fabric-dims=9,4 "
    "--fabric-offsets=4,1 --params=width:2,height:1 --memcpy "
    "--channels=1 --width-west-buf=0 --width-east-buf=0 -o out"
)
EFFECTIVE_ARGS = (
    "--arch=wse3 --fabric-dims=762,1172 --fabric-offsets=4,1 "
    "--params=width:2,height:1 --memcpy --channels=1 "
    "--width-west-buf=0 --width-east-buf=0"
)


def _add_bytes(handle: tarfile.TarFile, name: str, payload: bytes) -> None:
    info = tarfile.TarInfo(name)
    info.size = len(payload)
    info.mode = 0o644
    handle.addfile(info, io.BytesIO(payload))


def _archive(path: Path, *, unsafe: str | None = None, link: bool = False) -> None:
    with tarfile.open(path, "w:gz") as handle:
        _add_bytes(
            handle,
            "compiler/compile_command.sh",
            (f"cslc csl/layout.csl {EFFECTIVE_ARGS}\n").encode(),
        )
        _add_bytes(handle, "compiler/csl/layout.csl", b"layout {}\n")
        _add_bytes(handle, "compiler/out/bin/out_0_0.elf", b"ELF fixture")
        if unsafe:
            _add_bytes(handle, unsafe, b"escape")
        if link:
            info = tarfile.TarInfo("compiler/csl/link.csl")
            info.type = tarfile.SYMTYPE
            info.linkname = "/etc/passwd"
            handle.addfile(info)


def _frozen_layout(*, variants: int = 1) -> dict:
    variant = {
        "index": 0,
        "name": "out",
        "command": evidence_record(
            FROZEN_COMMAND, EvidenceKind.INFERRED, source="commands_wse3.sh"
        ),
        "layout": "./layout.csl",
        "output": "out",
        "arch": "wse3",
        "fabric_dimensions": {"x": 9, "y": 4},
        "fabric_offsets": {"x": 4, "y": 1},
        "params": {"height": "1", "width": "2"},
        "colors": {},
    }
    variant_records = [variant]
    if variants == 2:
        second = copy.deepcopy(variant)
        second.update({"index": 1, "name": "out-2", "output": "out-2"})
        variant_records.append(second)
    return {
        "schema_version": "1.0.0",
        "kind": "wse3-layout-inventory",
        "kernel": {"name": "Tiny", "csl_dir": "kernels/Tiny/CSL"},
        "compile": {
            "variants": variant_records,
            "memcpy": evidence_record(True, EvidenceKind.INFERRED, source="command"),
            "channels": evidence_record(1, EvidenceKind.INFERRED, source="command"),
            "width_west_buf": evidence_record(
                0, EvidenceKind.INFERRED, source="command"
            ),
            "width_east_buf": evidence_record(
                0, EvidenceKind.INFERRED, source="command"
            ),
        },
        "hashes": {
            "source_sha256": "canonical-source",
            "compile_command_sha256": "canonical-command",
            "artifacts_sha256": "canonical-artifacts",
            "inventory_sha256": "canonical-inventory",
        },
        "acceptance_qualification": {
            "status": "unqualified",
            "reasons": ["no bound SDK 2.10 artifact"],
        },
        "validation": {"status": "partial", "errors": [], "warnings": []},
    }


def _decoded_layout() -> dict:
    counts = {
        field: evidence_record(1, EvidenceKind.COMPILED, source="fixture")
        for field in LAYOUT_COUNT_FIELDS
    }
    counts["dynamically_active"] = evidence_record(
        None, EvidenceKind.INFERRED, source="not measured"
    )
    return {
        "schema_version": "1.0.0",
        "kind": "wse3-layout-inventory",
        "kernel": {"name": "Tiny"},
        "compile": {
            "toolchain": {
                "sdk_version": evidence_record(
                    None, EvidenceKind.INFERRED, source="fixture"
                ),
                "detected_sdk_versions": evidence_record(
                    None, EvidenceKind.INFERRED, source="fixture"
                ),
            }
        },
        "fabric": {
            "system_dimensions": evidence_record(
                {"width": 762, "height": 1172},
                EvidenceKind.DOCUMENTED,
                source="fixture",
            ),
            "dimensions": evidence_record(
                {"width": 762, "height": 1172},
                EvidenceKind.INFERRED,
                source="fixture",
            ),
            "allocation_dimensions": evidence_record(
                {"width": 762, "height": 1172},
                EvidenceKind.INFERRED,
                source="fixture",
            ),
            "offsets": evidence_record(
                {"x": 4, "y": 1}, EvidenceKind.INFERRED, source="fixture"
            ),
        },
        "application": {},
        "counts": counts,
        "resources": {},
        "pes": [
            {
                "fabric": {"x": 4, "y": 1},
                "logical": {"x": 0, "y": 0},
                "role": "application",
                "evidence": EvidenceKind.COMPILED.value,
            }
        ],
        "route_configs": [],
        "route_edges": [],
        "validation": {"status": "ok", "errors": [], "warnings": []},
        "unknowns": [],
        "acceptance_qualification": {"status": "qualified", "reasons": []},
        "hashes": {},
    }


class ArtifactBindingTests(unittest.TestCase):
    def test_archive_is_inspected_and_extracted_without_executing_shell(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "compiler.tar.gz"
            _archive(archive)
            inspected = inspect_compiler_archive(archive)
            self.assertEqual("csl/layout.csl", inspected["csl_main"])
            self.assertEqual([762, 1172], inspected["contract"]["fabric_dims"])
            self.assertEqual("2", inspected["contract"]["params"]["width"])
            extracted = root / "extracted"
            extract_compiler_archive(archive, extracted)
            self.assertTrue((extracted / "out/bin/out_0_0.elf").is_file())
            self.assertFalse((extracted / "compiler").exists())

    def test_archive_rejects_traversal_and_links(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            traversal = root / "traversal.tar.gz"
            _archive(traversal, unsafe="../escape")
            with self.assertRaisesRegex(ValidationError, "unsafe"):
                inspect_compiler_archive(traversal)
            linked = root / "linked.tar.gz"
            _archive(linked, link=True)
            with self.assertRaisesRegex(ValidationError, "link or special"):
                inspect_compiler_archive(linked)

    def _campaign_fixture(self, root: Path, *, variants: int = 1):
        campaign_dir = root / "campaign"
        artifact_dir = campaign_dir / "artifacts/Tiny/hardware/request-prefix"
        artifact_dir.mkdir(parents=True)
        archive = artifact_dir / "compiler.tar.gz"
        _archive(archive)
        request = {
            "request_key": "request-key",
            "subject": "Tiny",
            "kind": "suite",
            "arm": "hardware",
            "variant": "reference",
            "telemetry_level": "endpoint",
            "source_hash": "staged-source",
            "compile_hash": "declared-compile",
        }
        atomic_write_json(
            campaign_dir / "suite_requests.json", {"requests": [request]}
        )
        atomic_write_json(
            campaign_dir / "work/stages/Tiny.json",
            {
                "kernel": "Tiny",
                "canonical_source_hash": "canonical-source",
                "staged_source_hash": "staged-source",
                "compile_variant_count": 1,
                "compile_variant_index": 0,
                "staged_compile_command_sha256": canonical_hash(FROZEN_COMMAND),
            },
        )
        compile_identity = canonical_hash(
            {
                "compiled_bundle_hash": "compiled-bundle",
                "csl_main": "layout.csl",
                "compiler_args": EFFECTIVE_ARGS,
                "fabric_dims": [762, 1172],
                "arm": "hardware",
                "sdk_version": "2.10.1",
                "client_version": "2.10.0",
                "variant": "reference",
                "variant_index": 0,
            }
        )
        record = compile_record(
            request=request,
            compiler_archive=archive,
            artifact_original="/tmp/original.tar.gz",
            compiler_args=EFFECTIVE_ARGS,
            csl_main="layout.csl",
            compiled_bundle_hash="compiled-bundle",
            compile_identity_hash=compile_identity,
            source_hash_verified="staged-source",
            sdk_version="2.10.1",
            client_version="2.10.0",
            compile_variant_count=variants,
            compile_variant_index=0,
            compile_variant_command_sha256=canonical_hash(FROZEN_COMMAND),
        )
        atomic_write_json(artifact_dir / "compile.json", record)
        campaign = {
            "schema_version": "1.0.0",
            "kind": "wse3-characterization-campaign",
            "counts": {"discovered": 1, "campaign_qualified": 0, "complete": 0},
            "kernels": {"Tiny": _frozen_layout(variants=variants)},
        }
        return campaign_dir, campaign

    def test_exact_compile_chain_produces_campaign_qualified_layout(self):
        with tempfile.TemporaryDirectory() as temporary:
            campaign_dir, campaign = self._campaign_fixture(Path(temporary))
            with patch(
                "wse3study.artifact_binding.build_kernel_inventory",
                side_effect=lambda *args, **kwargs: _decoded_layout(),
            ):
                bound = bind_campaign_compile_artifacts(campaign, campaign_dir)
                rebound = bind_campaign_compile_artifacts(campaign, campaign_dir)
        layout = bound["kernels"]["Tiny"]
        self.assertEqual("qualified", layout["acceptance_qualification"]["status"])
        self.assertEqual(1, bound["counts"]["campaign_qualified"])
        self.assertEqual("2.10.1", layout["compile"]["toolchain"]["sdk_version"]["value"])
        self.assertEqual("staged-source", layout["hashes"]["source_sha256"])
        self.assertEqual("canonical-source", layout["hashes"]["canonical_source_sha256"])
        self.assertEqual(
            "canonical-command",
            layout["hashes"]["canonical_compile_command_sha256"],
        )
        self.assertEqual(
            "canonical-artifacts",
            layout["hashes"]["canonical_artifacts_sha256"],
        )
        self.assertEqual(
            "canonical-inventory",
            layout["hashes"]["canonical_inventory_sha256"],
        )
        self.assertEqual("compiled", layout["compile"]["artifact_binding"]["evidence"])
        self.assertEqual(bound["campaign_sha256"], rebound["campaign_sha256"])

    def test_multiple_variants_are_never_selected_implicitly(self):
        with tempfile.TemporaryDirectory() as temporary:
            campaign_dir, campaign = self._campaign_fixture(
                Path(temporary), variants=2
            )
            with patch(
                "wse3study.artifact_binding.build_kernel_inventory",
                side_effect=lambda *args, **kwargs: _decoded_layout(),
            ):
                bound = bind_campaign_compile_artifacts(campaign, campaign_dir)
        self.assertEqual(0, bound["counts"]["campaign_qualified"])
        summaries = bound["artifact_binding"]["summaries"]
        self.assertEqual("unqualified", summaries[0]["status"])
        self.assertTrue(
            any("multiple" in reason for reason in summaries[0]["reasons"])
        )


if __name__ == "__main__":
    unittest.main()
