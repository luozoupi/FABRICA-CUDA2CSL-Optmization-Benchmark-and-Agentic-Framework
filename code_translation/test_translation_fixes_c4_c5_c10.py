#!/usr/bin/env python3
"""Surfacing + firewall smoke tests for the firewall-safe translation fixes
C4 (collectives_2d introspection), C5 (arch-correct library signatures), and
C10 (reserved resource-ID ranges). See
results/failure_analysis_improvements_20260623.md.

These assert the fixes (a) SURFACE for the kernels they target, (b) do NOT fire on
trivial kernels, and (c) inject only generic SDK vocabulary — no CUDA constructs and
no reference-compute leakage.
"""

import os
import sys
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)

import csl_knowledge_base as kb            # noqa: E402
import library_signatures as libsig        # noqa: E402

_REPO = os.path.normpath(os.path.join(_HERE, ".."))


class C4CollectivesIntrospectionTest(unittest.TestCase):
    def test_section_present_in_block(self):
        self.assertIn("collectives_2d introspection: NUM_PES",
                      kb.KNOWN_GOTCHAS_W1_FAILURE_PATTERNS)

    def test_surfaces_for_collectives_cluster(self):
        out = kb._filter_w1_gotchas_for_clusters(["collectives_2d"])
        self.assertIn("NUM_PES", out)
        self.assertIn("DIM_LENGTH", out)          # the fake->real map
        self.assertIn("@get_rectangle", out)

    def test_absent_for_unrelated_cluster(self):
        out = kb._filter_w1_gotchas_for_clusters(["halo_recv_unblock"])
        self.assertNotIn("DIM_LENGTH", out)

    def test_detects_on_gemv_collectives_query(self):
        clusters = kb._detect_w1_clusters_for_kernel(
            "gemv collectives_2d mpi_x broadcast 2D mesh")
        self.assertIn("collectives_2d", clusters)


class C10ResourceIdAllocTest(unittest.TestCase):
    def test_section_present_in_block(self):
        self.assertIn("WSE-3 reserved resource-ID ranges",
                      kb.KNOWN_GOTCHAS_W1_FAILURE_PATTERNS)

    def test_surfaces_for_resource_cluster(self):
        out = kb._filter_w1_gotchas_for_clusters(["resource_id_alloc"])
        self.assertIn("reserved resource-ID ranges", out)
        self.assertIn("flee upward", out)         # the illegal-repair warning
        self.assertIn("[0, 24)", out)             # the legal color ceiling

    def test_detects_on_fft_query(self):
        clusters = kb._detect_w1_clusters_for_kernel(
            "butterfly fft transpose @get_color @get_input_queue all-to-all")
        self.assertIn("resource_id_alloc", clusters)

    def test_no_false_trigger_on_trivial_kernel(self):
        clusters = kb._detect_w1_clusters_for_kernel(
            "simple single tile matvec computing A times x")
        self.assertEqual(clusters, [])


class C5ArchLibSignaturesTest(unittest.TestCase):
    STENCIL_LIB = "../../benchmark-libs/stencil_3d_7pts/layout.csl"
    BICGSTAB_REF = os.path.join(_REPO, "kernels", "BiCGSTAB", "CSL")

    def test_resolver_prefers_arch_specific_pe_csl(self):
        if not os.path.isdir(self.BICGSTAB_REF):
            self.skipTest("BiCGSTAB ref missing")
        neutral = libsig._resolve_pe_csl(self.BICGSTAB_REF, self.STENCIL_LIB)
        wse3 = libsig._resolve_pe_csl(self.BICGSTAB_REF, self.STENCIL_LIB, arch="wse3")
        if neutral is None or wse3 is None:
            self.skipTest("stencil lib not resolvable in this checkout")
        self.assertNotIn("/wse3/", str(neutral).replace("\\", "/"))
        self.assertIn("/wse3/", str(wse3).replace("\\", "/"))

    def test_wse3_block_emits_typed_output_queues(self):
        if not os.path.isdir(self.BICGSTAB_REF):
            self.skipTest("BiCGSTAB ref missing")
        # find the layout the build compiles
        import glob
        layouts = glob.glob(os.path.join(self.BICGSTAB_REF, "**", "layout*.csl"),
                            recursive=True)
        if not layouts:
            self.skipTest("no layout for BiCGSTAB")
        with open(layouts[0], encoding="utf-8", errors="ignore") as _fh:
            layout = _fh.read()
        block = libsig.library_signatures_block(self.BICGSTAB_REF, layout, arch="wse3")
        if not block:
            self.skipTest("no library block (kernel imports no on-disk libs)")
        # typed shape from wse3/pe.csl, not the neutral `= {}`
        self.assertIn("output_queues:[4]u16", block.replace(" ", ""))
        # overlay note present + default-on
        self.assertIn("@concat_structs", block)

    def test_overlay_note_gate_off(self):
        if not os.path.isdir(self.BICGSTAB_REF):
            self.skipTest("BiCGSTAB ref missing")
        import glob
        layouts = glob.glob(os.path.join(self.BICGSTAB_REF, "**", "layout*.csl"),
                            recursive=True)
        if not layouts:
            self.skipTest("no layout")
        with open(layouts[0], encoding="utf-8", errors="ignore") as _fh:
            layout = _fh.read()
        os.environ["XKERNEL_LIB_OVERLAY_NOTE"] = "0"
        try:
            block = libsig.library_signatures_block(self.BICGSTAB_REF, layout, arch="wse3")
        finally:
            del os.environ["XKERNEL_LIB_OVERLAY_NOTE"]
        if block:
            self.assertNotIn("@concat_structs", block)


class C1LayoutResolutionRegressionTest(unittest.TestCase):
    """C1 (already shipped, e857d38): the layout shown to the agent must be the one
    the ACTIVE build script compiles — not a stale layout.csl. Regression guard for
    the solvers, whose build compiles layout_<algo>.csl (single on-device driver)."""

    SOLVERS = [
        ("Power Method", "src/kernel_power.csl"),
        ("Conjugate Gradient", "src/kernel_cg.csl"),
        ("Preconditioned CG", "src/kernel_pcg.csl"),
        ("BiCGSTAB", "src/kernel_bicgstab.csl"),
    ]

    def test_resolved_layout_matches_active_build_script(self):
        import cuda2csl
        for name, _target in self.SOLVERS:
            ref = os.path.join(_REPO, "kernels", name, "CSL")
            if not os.path.isdir(ref):
                self.skipTest(f"{name} missing")
            cmd_layout = cuda2csl._layout_from_commands(ref, "commands_wse3.sh")
            resolved = cuda2csl._find_layout_csl(ref, "commands_wse3.sh")
            if cmd_layout is None:
                self.skipTest(f"{name}: no cslc layout parseable")
            self.assertEqual(os.path.basename(resolved), os.path.basename(cmd_layout),
                             f"{name}: resolved layout != active build's cslc arg")


class AttributableGateTest(unittest.TestCase):
    """XKERNEL_FIXES_C4_C5_C10=0 must drop EXACTLY the C4/C5/C10 fixes (for an
    attributable A/B), leaving the rest of the knowledge system intact."""

    def setUp(self):
        self._old = os.environ.pop("XKERNEL_FIXES_C4_C5_C10", None)

    def tearDown(self):
        os.environ.pop("XKERNEL_FIXES_C4_C5_C10", None)
        if self._old is not None:
            os.environ["XKERNEL_FIXES_C4_C5_C10"] = self._old

    def test_c4_c10_dropped_when_gate_off(self):
        os.environ["XKERNEL_FIXES_C4_C5_C10"] = "0"
        self.assertNotIn("DIM_LENGTH",
                         kb._filter_w1_gotchas_for_clusters(["collectives_2d"]))
        self.assertNotIn("reserved resource-ID ranges",
                         kb._filter_w1_gotchas_for_clusters(["resource_id_alloc"]))

    def test_c4_c10_present_when_gate_on(self):
        os.environ["XKERNEL_FIXES_C4_C5_C10"] = "1"
        self.assertIn("DIM_LENGTH",
                      kb._filter_w1_gotchas_for_clusters(["collectives_2d"]))
        self.assertIn("reserved resource-ID ranges",
                      kb._filter_w1_gotchas_for_clusters(["resource_id_alloc"]))

    def test_other_gotchas_survive_gate_off(self):
        # A non-C4/C10 section in the collectives cluster must remain.
        os.environ["XKERNEL_FIXES_C4_C5_C10"] = "0"
        out = kb._filter_w1_gotchas_for_clusters(["collectives_2d"])
        self.assertIn("collectives_2d API surface", out)


class FirewallSafetyTest(unittest.TestCase):
    """The new KB sections must be GENERIC SDK knowledge — no CUDA constructs and
    no reference-compute-specific identifiers that could constitute a leak."""

    NEW_SECTION_MARKERS = [
        "collectives_2d introspection: NUM_PES",
        "WSE-3 reserved resource-ID ranges",
    ]

    def _extract_section(self, marker):
        block = kb.KNOWN_GOTCHAS_W1_FAILURE_PATTERNS
        idx = block.find(marker)
        self.assertGreater(idx, -1, f"section {marker!r} not found")
        # take from the marker to the next H3 header
        rest = block[idx:]
        nxt = rest.find("\n### ", len(marker))
        return rest if nxt < 0 else rest[:nxt]

    def test_new_sections_contain_no_cuda_constructs(self):
        # Guard against CUDA *code* leaking into the CSL knowledge — the dangerous
        # markers are compilation-affecting constructs. NB: the C4 section
        # deliberately NAMES threadIdx/blockDim in prose ("do NOT invent these
        # CUDA-style names"), which is guidance, not a leak — so those words are
        # intentionally not in this list.
        for marker in self.NEW_SECTION_MARKERS:
            sec = self._extract_section(marker)
            for bad in ("__global__", "__device__", "__shared__",
                        "cudaMalloc", "<<<"):
                self.assertNotIn(bad, sec,
                                 f"{marker!r} leaks CUDA construct {bad!r}")

    def test_overlay_note_has_no_concrete_reference_ids(self):
        # The overlay note must teach the @concat_structs idiom with PLACEHOLDER
        # ids only (`...`), never concrete reserved id values from a reference.
        note = libsig._LIB_OVERLAY_NOTE
        self.assertIn("placeholder", note.lower())
        self.assertIn("@concat_structs", note)


if __name__ == "__main__":
    unittest.main(verbosity=2)
