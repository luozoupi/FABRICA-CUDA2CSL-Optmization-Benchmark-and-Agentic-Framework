"""Integrity of the sparse task suite S: registry, spec blocks, build scripts, caps against the
matrix manifests after the spec's partition, manifest checksums, the shared module copies,
runner conventions, timing contract, and the held-out firewall."""
import hashlib
import json
import re
import unittest
from pathlib import Path

import yaml

import benchmark_csl as bc
import check_timing_integrity as cti
import cuda2csl
import sparse_inputs as si
import task_sets as ts
import timing_protocol as tp

REPO = Path(__file__).resolve().parents[1]
CANON = (REPO / "code_translation" / "sparse_inputs.py").read_bytes()
# Storage-format study (2026-10-04): a synthetic block-structured class, not a member of S.
STUDY = ["SpMV-CSR-Block"]
MEMBERS = ts.S + STUDY


def spec_of(k):
    return yaml.safe_load((REPO / "kernels" / k / "spec.yaml").read_text())


def caps_of(params):
    rows = params.get("nrows_pe") or params.get("Mt") or params.get("nrows") or params.get("n")
    nnz = params.get("max_nnz_pe") or params.get("max_nnz")
    cols = params.get("ncols") or params.get("K") or rows
    return int(rows), int(nnz), int(cols), int(params.get("P", 1))


class SuiteTests(unittest.TestCase):
    def test_every_member_is_registered_with_the_v2_blocks(self):
        for k in MEMBERS:
            spec = spec_of(k)
            self.assertIn(k, cuda2csl.KERNEL_REGISTRY, k)
            self.assertEqual(spec["group"], "sparse", k)
            for block in ("structure", "eval", "sizes", "hidden_from_optimize_only"):
                self.assertIn(block, spec, f"{k}: {block}")
            self.assertTrue(spec["structure"].get("readout"), k)
            self.assertEqual(spec["eval"]["heldout_seeds"], [101, 202, 303], k)

    def test_commands_scripts_exist_with_one_literal_params_group(self):
        for k in MEMBERS:
            for s in spec_of(k)["sizes"]:
                script = REPO / "kernels" / k / "CSL" / s["commands_script"]
                self.assertTrue(script.is_file(), f"{k}[{s['name']}]: {script.name} missing")
                text = script.read_text()
                groups = re.findall(r"--params=(\S+)", text)
                self.assertEqual(len(groups), 1, f"{k}[{s['name']}]: expected one --params group")
                self.assertNotIn("$", groups[0], f"{k}[{s['name']}]: --params must be literal")
                got = {kv.split(":")[0]: int(kv.split(":")[1]) for kv in groups[0].split(",")}
                self.assertEqual(got, {a: int(b) for a, b in s["params"].items()}, f"{k}[{s['name']}]")

    def test_caps_hold_for_every_matrix_of_every_size(self):
        for k in MEMBERS:
            spec = spec_of(k)
            if spec["structure"].get("generator"):
                continue                                   # synthetic class (SpMV-CSR)
            for s in spec["sizes"]:
                rows, nnz, cols, P = caps_of(s["params"])
                sid = int(s["params"].get("structure_id", 0))
                man = REPO / "kernels" / k / "CSL" / "data" / ("manifest.json" if sid == 0 else f"manifest_{sid}.json")
                self.assertTrue(man.is_file(), f"{k}[{s['name']}]: {man.name}")
                entries = json.loads(man.read_text())["matrices"]
                self.assertGreaterEqual(len(entries), 4, f"{k}[{s['name']}]: need a train and 3 held-out matrices")
                for e in entries:
                    f = man.parent / e["file"]
                    self.assertEqual(hashlib.sha256(f.read_bytes()).hexdigest(), e["sha256"], f"{k}: {e['id']} checksum")
                    c = si.read_mtx(f)
                    self.assertEqual((c.n, c.m, c.nnz), (e["n"], e["m"], e["nnz"]), f"{k}: {e['id']} dims")
                    self.assertLessEqual(c.n, P * rows, f"{k}[{s['name']}]: {e['id']} rows")
                    self.assertLessEqual(c.m, cols, f"{k}[{s['name']}]: {e['id']} cols")
                    local = max(p.nnz for p in si.partition_row_block(c, P, rows)) if P > 1 else c.nnz
                    self.assertLessEqual(local, nnz, f"{k}[{s['name']}]: {e['id']} nnz per PE {local} > cap {nnz}")
                    if spec["structure"]["format"] == "csc":
                        self.assertEqual(c.n, c.m, f"{k}: {e['id']} must be square")

    def test_seed_to_index_never_returns_train_for_heldout(self):
        for k in MEMBERS:
            spec = spec_of(k)
            if spec["structure"].get("generator"):
                continue
            n = len(json.loads((REPO / "kernels" / k / "CSL" / "data" / "manifest.json").read_text())["matrices"])
            idx = [si.seed_to_index(s, spec["eval"]["train_seed"], n) for s in spec["eval"]["heldout_seeds"]]
            self.assertNotIn(0, idx, k)
            self.assertEqual(len(set(idx)), len(idx), f"{k}: held-out seeds collide on a matrix")

    def test_module_copies_and_runner_conventions(self):
        for k in MEMBERS:
            csl = REPO / "kernels" / k / "CSL"
            spec = spec_of(k)
            if not spec["structure"].get("generator"):
                self.assertEqual((csl / "sparse_inputs.py").read_bytes(), CANON, f"{k}: sparse_inputs.py copy out of sync")
                run = (csl / "run.py").read_text()
                self.assertIn("resolve_eval_seed", run, k)
                self.assertIn('print(f"eval_seed = {SEED}")', run, k)
            run = (csl / "run.py").read_text()
            self.assertNotRegex(run, r"add_argument\(\s*[\"']--seed", f"{k}: run.py must not take --seed")
            ok, why = cti.check_success_gated(run)
            self.assertTrue(ok, f"{k}: {why}")
            layout = (csl / "layout.csl").read_text()
            self.assertNotRegex(layout, r"@export_name\([^)]*\[\*\][^)]*,\s*false\)", f"{k}: immutable export")
            self.assertNotIn("comptime_struct", (csl / "pe.csl").read_text(), f"{k}: pe.csl must be SDK 2.10-native")

    def test_timing_contract(self):
        for k in MEMBERS:
            spec = spec_of(k); pe = (REPO / "kernels" / k / "CSL" / "pe.csl").read_text()
            if spec.get("timing_protocol") == "device_internal_v2":
                self.assertTrue(tp.uses_protocol(pe), k)
                self.assertIsNone(tp.check_device_window_contract(pe), k)
                self.assertIn("f_tic_dev", spec.get("frozen_functions", []), k)
            else:
                self.assertIn("compute", spec.get("frozen_functions", []), f"{k}: 1-PE tasks freeze compute()")
                ok, why = cti.check_device_window(pe)
                self.assertTrue(ok, f"{k}: {why}")

    def test_firewall_no_heldout_matrix_in_agent_visible_text(self):
        for k in MEMBERS:
            spec = spec_of(k)
            if spec["structure"].get("generator"):
                continue
            csl = REPO / "kernels" / k / "CSL"
            entries = json.loads((csl / "data" / "manifest.json").read_text())["matrices"]
            heldout = [Path(e["file"]).stem for e in entries[1:]] + [e["id"] for e in entries[1:]]
            visible = cuda2csl.spec_task_summary(spec) + "\n" + (si.readout_for_kernel(csl) or "")
            contract = cuda2csl.build_reference_contract(reference_dir=str(csl), target_relpath="pe.csl",
                                                         commands_script=spec["sizes"][0]["commands_script"], max_chars=200000)[0]
            visible += "\n" + contract
            for h in heldout:
                self.assertNotIn(h, visible, f"{k}: held-out matrix {h} visible to the agent")

    def test_generator_classes_hold_their_caps(self):
        for k in MEMBERS:
            spec = spec_of(k)
            gen = spec["structure"].get("generator")
            if not gen:
                continue
            caps = spec["structure"]["caps"]
            seeds = [spec["eval"]["train_seed"]] + spec["eval"]["heldout_seeds"]
            for s in spec["sizes"]:
                p = s["params"]
                self.assertEqual((p["nrows"], p["max_nnz"]), (caps["nrows"], caps["max_nnz"]), f"{k}[{s['name']}]")
                if gen["kind"] == "block_random":
                    for seed in seeds:
                        c = si.generate("block_random", seed, n=p["nrows"])
                        self.assertLessEqual(c.nnz, p["max_nnz"], f"{k}: seed {seed}")
                        self.assertIn("struct_blocked", si.structure_keys(si.features(c)), f"{k}: seed {seed}")


if __name__ == "__main__":
    unittest.main()
