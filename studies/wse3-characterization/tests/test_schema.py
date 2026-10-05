from __future__ import annotations

import copy
import sys
import unittest
from pathlib import Path


STUDY_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = STUDY_ROOT.parents[1]
sys.path.insert(0, str(STUDY_ROOT))

from wse3study.inventory import build_kernel_inventory  # noqa: E402
from wse3study.schema import (  # noqa: E402
    validate_layout_contract,
    validate_wavelet_contract,
)
from wse3study.trace import CoordinateMapper, build_wavelet_groups  # noqa: E402


class ArtifactContractTests(unittest.TestCase):
    def test_real_compiled_layout_satisfies_stable_contract(self) -> None:
        layout = build_kernel_inventory("ParBroadcast-Scale", REPO_ROOT)
        self.assertEqual([], validate_layout_contract(layout))

    def test_non_cardinal_route_is_rejected(self) -> None:
        layout = build_kernel_inventory("ParBroadcast-Scale", REPO_ROOT)
        broken = copy.deepcopy(layout)
        edge = broken["route_edges"][0]
        edge["to"]["x"] = edge["from"]["x"] + 2
        self.assertTrue(
            any("not cardinally adjacent" in error for error in validate_layout_contract(broken))
        )

    def test_wavelet_records_require_stable_nullable_fields(self) -> None:
        mapper = CoordinateMapper(2, 1)
        groups = build_wavelet_groups(
            [
                {
                    "event_type": "wavelet_trace_entry",
                    "cycle": 1,
                    "ident": 7,
                    "tile_id": 0,
                    "fields": 0,
                    "evidence": "simulator",
                }
            ],
            mapper=mapper,
        )
        self.assertEqual([], validate_wavelet_contract(groups[0]))
        broken = copy.deepcopy(groups[0])
        del broken["nodes"][0]["color"]
        self.assertIn("nodes[0].color is missing", validate_wavelet_contract(broken))


if __name__ == "__main__":
    unittest.main()
