from __future__ import annotations

import io
import json
import shutil
import stat
import struct
import sys
import tarfile
import tempfile
import unittest
import zipfile
from pathlib import Path


STUDY_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(STUDY_ROOT))

from wse3study.schema import ValidationError, atomic_write_json, hash_file  # noqa: E402
from wse3study.trace import CTF_MAGIC  # noqa: E402
from wse3study.trace_artifacts import (  # noqa: E402
    bind_simulator_trace_artifact,
    compare_csdb_to_ctf,
    discover_simulator_trace_exports,
    ingest_simulator_trace_artifact,
    inspect_log_export_zip,
    parse_csdb_wavelet_logs,
)


MINIMAL_METADATA = r'''/* CTF 1.8 */
trace {
  major = 1;
  minor = 8;
  byte_order = le;
};
event {
  stream_id = 0;
  id = 6;
  name = "wavelet_trace_entry";
  fields := struct {
    integer { signed = false; size = 64; align = 64; } cycle;
    integer { signed = false; size = 64; align = 64; } ident;
    integer { signed = false; size = 32; align = 32; } tile_index;
    integer { signed = false; size = 16; align = 16; } index;
    integer { signed = false; size = 16; align = 16; } data;
    integer { signed = false; size = 32; align = 32; } fields;
  } align(1);
};
'''


def _wavelet_packet(*, cycle: int, ident: int, tile: int) -> bytes:
    packet = bytearray(72)
    struct.pack_into("<IQ", packet, 0, CTF_MAGIC, 0)
    struct.pack_into("<QQ", packet, 52, 6, cycle)
    packet.extend(struct.pack("<QQIHHI", cycle, ident, tile, 1, 2, 3))
    size = len(packet)
    struct.pack_into("<5Q", packet, 12, size * 8, size * 8, cycle, cycle, 0)
    return bytes(packet)


def _add_tar_file(handle: tarfile.TarFile, name: str, data: bytes) -> None:
    info = tarfile.TarInfo(name)
    info.size = len(data)
    info.mode = 0o644
    handle.addfile(info, io.BytesIO(data))


def _compiler_archive(path: Path) -> None:
    command = (
        "cslc csl/layout.csl --arch=wse3 --fabric-dims=2,1 "
        "--fabric-offsets=0,0 --params=width:2,height:1\n"
    ).encode()
    with tarfile.open(path, "w:gz") as handle:
        _add_tar_file(handle, "bundle/compile_command.sh", command)
        _add_tar_file(handle, "bundle/csl/layout.csl", b"const x: u16 = 1;\n")
        _add_tar_file(handle, "bundle/out/bin/out_0_0.elf", b"ELF-test")


def _write_zip_from_tree(path: Path, root: Path, *, unsafe: bool = False) -> None:
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as handle:
        top = root.name
        directory = zipfile.ZipInfo(top + "/")
        directory.external_attr = (stat.S_IFDIR | 0o755) << 16
        handle.writestr(directory, b"")
        for source in sorted(root.rglob("*")):
            relative = source.relative_to(root).as_posix()
            archive_name = f"{top}/{relative}"
            if source.is_dir():
                info = zipfile.ZipInfo(archive_name + "/")
                info.external_attr = (stat.S_IFDIR | 0o755) << 16
                handle.writestr(info, b"")
            elif not source.name.startswith("wavelet-trace-"):
                info = zipfile.ZipInfo(archive_name)
                info.external_attr = (stat.S_IFREG | 0o644) << 16
                handle.writestr(info, source.read_bytes())
        if unsafe:
            handle.writestr(f"{top}/../escape", b"bad")


class TraceArtifactFixture:
    def __init__(self, root: Path) -> None:
        self.campaign = root / "campaign"
        self.artifacts = self.campaign / "artifacts"
        self.job_id = "wsjob-test123"
        self.event_key = "e" * 64
        self.request_key = "r" * 64
        self.subject = "tiny-trace"
        preserved_dir = (
            self.artifacts
            / self.subject
            / "simulator"
            / self.request_key[:16]
        )
        preserved_dir.mkdir(parents=True)
        self.preserved = preserved_dir / "cs_fixture.tar.gz"
        _compiler_archive(self.preserved)
        artifact_sha = hash_file(self.preserved)
        artifact_bytes = self.preserved.stat().st_size
        compiler_args = (
            "--arch=wse3 --fabric-dims=2,1 --fabric-offsets=0,0 "
            "--params=width:2,height:1"
        )
        compile_identity = "i" * 64
        compiled_bundle = "b" * 64
        source_hash = "s" * 64
        compile_hash = "c" * 64
        atomic_write_json(
            preserved_dir / "compile.json",
            {
                "request_key": self.request_key,
                "subject": self.subject,
                "arm": "simulator",
                "source_hash": source_hash,
                "declared_compile_hash": compile_hash,
                "compile_identity_hash": compile_identity,
                "compiled_bundle_hash": compiled_bundle,
                "compiler_args": compiler_args,
                "artifact_sha256": artifact_sha,
                "artifact_bytes": artifact_bytes,
            },
        )

        export_name = f"log-export-{self.job_id}-fixture"
        self.export = self.artifacts / "extracted" / export_name
        workdir = self.export / "coordinator-0" / "cs_fixture"
        trace_dir = workdir / "simfab_traces"
        trace_dir.mkdir(parents=True)
        shutil.copyfile(self.preserved, workdir / self.preserved.name)
        (workdir / "compile_command.sh").write_text(
            f"cslc csl/layout.csl {compiler_args}\n", encoding="utf-8"
        )
        (trace_dir / "metadata").write_text(MINIMAL_METADATA, encoding="utf-8")
        (trace_dir / "stream0").write_bytes(
            _wavelet_packet(cycle=12, ident=1, tile=0)
            + _wavelet_packet(cycle=13, ident=2, tile=1)
        )
        atomic_write_json(trace_dir / "global_simdata.json", {"xsize": 2, "ysize": 1})
        (self.export / f"{self.job_id}.yaml").write_text(
            f"apiVersion: jobs.cerebras.com/v1\nkind: WSJob\nmetadata:\n  name: {self.job_id}\n",
            encoding="utf-8",
        )
        (workdir / "wavelet-trace-x0y0.log").write_text(
            "Cycle    Color    Ctrl    Link    Index    Data\n"
            "-------  -------  ------  ------  -------  ------\n"
            "     12        5       0  E       0x1      0x2\n",
            encoding="utf-8",
        )
        (workdir / "wavelet-trace-x1y0.log").write_text(
            "Cycle    Color    Ctrl    Link    Index    Data\n"
            "-------  -------  ------  ------  -------  ------\n"
            "     13        5       1  R       0x1      0x2\n",
            encoding="utf-8",
        )
        self.workdir = workdir
        zip_dir = self.artifacts / "log-export"
        zip_dir.mkdir(parents=True)
        self.zip_path = zip_dir / f"{export_name}.zip"
        _write_zip_from_tree(self.zip_path, self.export)

        request = {
            "request_key": self.request_key,
            "subject": self.subject,
            "arm": "simulator",
            "source_hash": source_hash,
            "compile_hash": compile_hash,
        }
        result = {
            "job_id": self.job_id,
            "source_hash_verified": source_hash,
            "compile_identity_hash": compile_identity,
            "compiled_bundle_hash": compiled_bundle,
            "compiler_args": compiler_args,
            "artifact_sha256": artifact_sha,
            "artifact_bytes": artifact_bytes,
            "fabric_dims": [2, 1],
            "start_words_u16": [10, 0, 0],
            "end_words_u16": [20, 0, 0],
            "source_pe": [0, 0],
            "destination_pe": [1, 0],
            "elapsed_cycles": 10,
            "timing_method": "device_internal_synchronized",
            "timer_validated": True,
            "correctness": True,
        }
        provenance = {
            **{
                key: result[key]
                for key in (
                    "job_id",
                    "source_hash_verified",
                    "compile_identity_hash",
                    "compiled_bundle_hash",
                    "compiler_args",
                    "artifact_sha256",
                    "artifact_bytes",
                    "fabric_dims",
                )
            },
            "artifact_id": self.preserved.name,
            "artifact_preserved": str(self.preserved),
            "sdk_version": "2.10.0",
            "client_version": "2.10.0",
            "cerebras_appliance_version": "2.10.0",
        }
        record = {
            "event_key": self.event_key,
            "request_key": self.request_key,
            "subject": self.subject,
            "kind": "calibration",
            "arm": "simulator",
            "source_hash": source_hash,
            "compile_hash": compile_hash,
            "accepted": True,
            "trial": 0,
            "warmup": False,
            "request": request,
            "result": result,
            "provenance": provenance,
        }
        self.campaign.mkdir(parents=True, exist_ok=True)
        (self.campaign / "ledger.jsonl").write_text(
            json.dumps(record, sort_keys=True) + "\n", encoding="utf-8"
        )


class SafeDiscoveryTests(unittest.TestCase):
    def test_discovery_correlates_ledger_zip_and_extraction(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fixture = TraceArtifactFixture(Path(temporary))
            report = discover_simulator_trace_exports(fixture.campaign)
        job = next(item for item in report["jobs"] if item["job_id"] == fixture.job_id)
        self.assertTrue(job["binding_candidate"])
        self.assertEqual(1, job["accepted_simulator_event_count"])
        self.assertEqual("metadata-only; no ZIP member was extracted", report["retained_zips"][0]["inspection"])

    def test_zip_traversal_member_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fixture = TraceArtifactFixture(Path(temporary))
            unsafe = fixture.zip_path.with_name(
                f"log-export-{fixture.job_id}-unsafe.zip"
            )
            _write_zip_from_tree(unsafe, fixture.export, unsafe=True)
            with self.assertRaisesRegex(
                ValidationError, "unsafe log-export member path"
            ):
                inspect_log_export_zip(unsafe)


class BindingAndCrosscheckTests(unittest.TestCase):
    def test_exact_chain_binds_and_csdb_matches_ctf_per_pe(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fixture = TraceArtifactFixture(Path(temporary))
            binding = bind_simulator_trace_artifact(
                fixture.campaign, job_id=fixture.job_id
            )
            csdb = parse_csdb_wavelet_logs(
                binding["workdir"],
                coordinate_contract=binding["coordinate_contract"],
            )
            crosscheck = compare_csdb_to_ctf(binding, csdb)
        self.assertEqual("qualified", binding["status"])
        self.assertEqual(2, binding["device_tsc_window"]["crop_event_count"])
        self.assertEqual("match", crosscheck["status"])
        self.assertEqual(2, crosscheck["ctf"]["event_count"])
        self.assertTrue(crosscheck["per_pe_match"])
        record = csdb["records"][1]
        self.assertEqual("simulator", record["evidence"])
        self.assertEqual({"x": 1, "y": 0}, {
            "x": record["coordinates"]["application"]["x"],
            "y": record["coordinates"]["application"]["y"],
        })
        self.assertIn("not a hardware", record["limitations"])

    def test_per_pe_mismatch_is_detected_even_when_totals_match(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fixture = TraceArtifactFixture(Path(temporary))
            binding = bind_simulator_trace_artifact(
                fixture.campaign, job_id=fixture.job_id
            )
            first = fixture.workdir / "wavelet-trace-x0y0.log"
            second = fixture.workdir / "wavelet-trace-x1y0.log"
            second_lines = second.read_text(encoding="utf-8").splitlines()
            first.write_text(
                "\n".join(second_lines + [second_lines[-1]]) + "\n",
                encoding="utf-8",
            )
            second.write_text(
                "Cycle    Color    Ctrl    Link    Index    Data\n"
                "-------  -------  ------  ------  -------  ------\n",
                encoding="utf-8",
            )
            csdb = parse_csdb_wavelet_logs(
                binding["workdir"],
                coordinate_contract=binding["coordinate_contract"],
            )
            crosscheck = compare_csdb_to_ctf(binding, csdb)
        self.assertTrue(crosscheck["total_match"])
        self.assertFalse(crosscheck["per_pe_match"])
        self.assertEqual("mismatch", crosscheck["status"])

    def test_multiple_windows_on_one_job_require_event_key(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fixture = TraceArtifactFixture(Path(temporary))
            ledger = fixture.campaign / "ledger.jsonl"
            second = json.loads(ledger.read_text(encoding="utf-8"))
            second["event_key"] = "f" * 64
            with ledger.open("a", encoding="utf-8") as handle:
                handle.write(json.dumps(second) + "\n")
            with self.assertRaisesRegex(
                ValidationError, "exactly one accepted simulator"
            ):
                bind_simulator_trace_artifact(fixture.campaign, job_id=fixture.job_id)
            selected = bind_simulator_trace_artifact(
                fixture.campaign,
                job_id=fixture.job_id,
                event_key=fixture.event_key,
            )
        self.assertEqual(fixture.event_key, selected["event_key"])

    def test_ingestion_persists_evidence_records_and_crosscheck(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            fixture = TraceArtifactFixture(Path(temporary))
            output = Path(temporary) / "output"
            result = ingest_simulator_trace_artifact(
                fixture.campaign,
                job_id=fixture.job_id,
                output_dir=output,
            )
            crosscheck = json.loads(Path(result["crosscheck"]).read_text())
            manifest = json.loads(Path(result["manifest"]).read_text())
        self.assertEqual("qualified", result["status"])
        self.assertEqual("match", crosscheck["status"])
        self.assertEqual("simulator", manifest["evidence"])
        self.assertTrue(Path(result["csdb_records"]).name.endswith(".jsonl.gz"))


if __name__ == "__main__":
    unittest.main()
