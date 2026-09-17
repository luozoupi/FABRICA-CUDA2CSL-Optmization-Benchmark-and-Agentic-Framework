"""Catalog integrity for the model-derived optimization angles."""
import unittest

import prompt_cuda2csl as pc
import wse3_model as wm

REQUIRED = ("description", "applicable_groups", "applicable_bottlenecks", "source_skill", "knowledge_query_hint")


class CatalogTest(unittest.TestCase):
    def test_every_angle_has_required_fields(self):
        for name, meta in pc.CSL_OPTIMIZATION_STEPS_CATALOG.items():
            for key in REQUIRED:
                self.assertIn(key, meta, f"{name} lacks {key}")
            self.assertTrue(meta["description"].strip(), name)

    def test_model_angles_exist_with_flags(self):
        for name in pc.MODEL_CSL_OPT_STEPS:
            self.assertIn(name, pc.CSL_OPTIMIZATION_STEPS_CATALOG, name)
        self.assertTrue(pc.CSL_OPTIMIZATION_STEPS_CATALOG["f16_precision"].get("requires_precision_ok"))
        self.assertTrue(pc.CSL_OPTIMIZATION_STEPS_CATALOG["bank_class_offset"].get("hardware_validated"))
        self.assertTrue(pc.CSL_OPTIMIZATION_STEPS_CATALOG["turn_free_routing"].get("codesign_only"))

    def test_model_keys_are_reachable_from_angles(self):
        used = set()
        for meta in pc.CSL_OPTIMIZATION_STEPS_CATALOG.values():
            used.update(k for k in meta.get("applicable_bottlenecks", []) if k.startswith("model_"))
        for key in wm.MODEL_KEYS:
            if key in ("model_io_dominated", "model_far_from_bound"):
                # informational keys: I/O domination needs a task-level change (fuse/batch),
                # and distance from the lower bound says headroom exists, not which lever
                continue
            self.assertIn(key, used, f"no angle is triggered by {key}")
        self.assertTrue(used <= set(wm.MODEL_KEYS), used - set(wm.MODEL_KEYS))

    def test_default_whitelist_unchanged(self):
        self.assertEqual(pc.DEFAULT_CSL_OPT_STEPS, ["task_simplify", "buffer_cleanup", "comptime_cleanup",
                                                    "dsd_offset_chaining", "fmac_bulk", "comptime_hoist"])
        self.assertTrue(set(pc.DEFAULT_CSL_OPT_STEPS).isdisjoint(pc.MODEL_CSL_OPT_STEPS[:2]))


if __name__ == "__main__":
    unittest.main()
