from __future__ import annotations

import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path


STUDY_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = STUDY_ROOT.parents[1]
sys.path.insert(0, str(STUDY_ROOT))

from wse3study.inventory import (  # noqa: E402
    _active_compile_variant_selection,
    _resource_inventory,
    build_campaign_inventory,
    build_kernel_inventory,
    discover_active_kernels,
    parse_compile_command,
    parse_compile_commands,
    write_inventory,
)
from wse3study.svg import render_full_fabric_svg, render_zoom_svg  # noqa: E402


class _FakeReadelf:
    def __init__(self) -> None:
        self.calls: list[tuple[Path, tuple[str, ...]]] = []

    def run(self, elf_path: Path, flags: tuple[str, ...]) -> str:
        self.calls.append((elf_path, tuple(flags)))
        return """
(4,1): 5808 bytes (2904 words)
user_buffer: addr=0x1200, size=128, banks=[2,3]
"""


class InventoryTests(unittest.TestCase):
    def test_wse3_ut_id_resources_are_discovered(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory)
            (bundle / "pe.csl").write_text(
                "const u0 = @get_ut_id(0);\nconst u7 = @get_ut_id(7);\n",
                encoding="utf-8",
            )
            resources = _resource_inventory(bundle, {})
        self.assertEqual([0, 7], resources["microthread_ids"]["value"])

    def test_active_suite_is_discovered_from_sweep_and_registry(self) -> None:
        kernels = discover_active_kernels(REPO_ROOT)
        names = [item["name"] for item in kernels]
        self.assertEqual(49, len(names))
        self.assertEqual(len(names), len(set(names)))
        self.assertIn("ParBroadcast-Scale", names)
        self.assertIn("LorenzoPredictor-Tile", names)
        self.assertNotIn("MC-Particle-Transport", names)
        par = next(item for item in kernels if item["name"] == "ParBroadcast-Scale")
        self.assertEqual("kernels/ParBroadcast-Scale/CSL", par["csl_dir"])
        self.assertEqual("test", par["sweep"]["split"])

    def test_actual_command_parser_preserves_compile_contract(self) -> None:
        command = parse_compile_command(
            REPO_ROOT / "kernels/ParBroadcast-Scale/CSL/commands_wse3.sh"
        )
        self.assertEqual("./layout.csl", command["layout"])
        self.assertEqual("wse3", command["arch"])
        self.assertEqual({"x": 11, "y": 3}, command["fabric_dimensions"])
        self.assertEqual({"x": 4, "y": 1}, command["fabric_offsets"])
        self.assertEqual("4", command["params"]["width"])
        self.assertEqual("out", command["output"])
        self.assertTrue(command["memcpy"])

        fft_commands = parse_compile_commands(
            REPO_ROOT / "kernels/FFT 1D-2D/CSL/commands_wse3.sh"
        )
        self.assertEqual(["out-1D", "out-2D"], [item["output"] for item in fft_commands])
        fft_2d = build_kernel_inventory("FFT-1D-2D", REPO_ROOT, compile_variant=1)
        self.assertEqual(1, fft_2d["compile"]["selected_variant"])
        self.assertEqual(4, fft_2d["application"]["rectangle"]["value"]["width"])

    def test_campaign_selects_fft_variant_from_active_registry_target(self) -> None:
        campaign = build_campaign_inventory(REPO_ROOT, only=["FFT-1D-2D"])
        compile_record = campaign["kernels"]["FFT-1D-2D"]["compile"]
        self.assertEqual(1, compile_record["selected_variant"])
        self.assertEqual(
            ["out-1D", "out-2D"],
            [variant["name"] for variant in compile_record["variants"]],
        )
        selection = compile_record["selected_variant_selection"]
        self.assertEqual(1, selection["index"])
        self.assertEqual("ucode_2d.csl", selection["registry_target_relpath"])
        self.assertEqual({"DIM": "2"}, selection["selection_parameter"])
        self.assertIn("active sweep registry targets", selection["reason"])
        self.assertEqual([0], selection["unselected_variants_retained"])

    def test_unknown_multi_variant_bundle_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            bundle = root / "kernels" / "Ambiguous" / "CSL"
            bundle.mkdir(parents=True)
            (bundle / "commands_wse3.sh").write_text(
                "cslc layout.csl --params=MODE:0 -o out-a\n"
                "cs_python run.py --name out-a\n"
                "cslc layout.csl --params=MODE:1 -o out-b\n"
                "cs_python run.py --name out-b\n",
                encoding="utf-8",
            )
            (bundle / "layout.csl").write_text(
                'layout { @set_rectangle(1, 1); @set_tile_code(0, 0, "pe.csl", .{}); }\n',
                encoding="utf-8",
            )
            entry = {
                "name": "Ambiguous",
                "csl_dir": "kernels/Ambiguous/CSL",
                "commands_script": "commands_wse3.sh",
                "target_relpath": "pe.csl",
            }
            with self.assertRaisesRegex(Exception, "does not prove one"):
                _active_compile_variant_selection(entry, root)

    def test_compiled_elf_coordinates_and_broadcast_route_are_exact(self) -> None:
        layout = build_kernel_inventory("ParBroadcast-Scale", REPO_ROOT)
        self.assertEqual("ok", layout["validation"]["status"])
        application = [pe for pe in layout["pes"] if pe["role"] == "application"]
        self.assertEqual(
            [(4, 1), (5, 1), (6, 1), (7, 1)],
            [(pe["fabric"]["x"], pe["fabric"]["y"]) for pe in application],
        )
        self.assertEqual(
            [(0, 0), (1, 0), (2, 0), (3, 0)],
            [(pe["logical"]["x"], pe["logical"]["y"]) for pe in application],
        )
        self.assertTrue(all(pe["evidence"] == "compiled" for pe in application))
        self.assertEqual("compiled", layout["application"]["exports"]["evidence"])
        self.assertIn("compute", layout["application"]["exports"]["value"])
        app_east = [
            edge
            for edge in layout["route_edges"]
            if edge["traffic_class"] == "application"
            and edge["color"] == 8
            and edge["direction"] == "east"
        ]
        self.assertEqual(3, len(app_east))
        self.assertTrue(all(edge["destination_validation"] == "matched" for edge in app_east))
        self.assertEqual(4, layout["counts"]["application_loaded"]["value"])
        self.assertGreater(layout["counts"]["io_loaded"]["value"], 0)
        self.assertGreater(layout["counts"]["routing_only"]["value"], 0)
        self.assertIsNone(layout["counts"]["dynamically_active"]["value"])
        self.assertEqual(
            {"width": 762, "height": 1172},
            layout["fabric"]["system_dimensions"]["value"],
        )
        self.assertEqual("documented", layout["fabric"]["system_dimensions"]["evidence"])
        self.assertEqual(["1.4.0"], layout["compile"]["toolchain"]["detected_sdk_versions"]["value"])
        self.assertEqual("unqualified", layout["acceptance_qualification"]["status"])
        self.assertTrue(
            any("SDK 2.10" in reason for reason in layout["acceptance_qualification"]["reasons"])
        )
        app_resources = application[0]["resources"]
        self.assertEqual("compiled", app_resources["colors"]["evidence"])
        self.assertEqual("inferred", app_resources["task_ids"]["evidence"])

    def test_two_dimensional_elf_mapping_does_not_treat_image_id_as_x(self) -> None:
        layout = build_kernel_inventory("Jacobi-2D-5pt", REPO_ROOT)
        application = [pe for pe in layout["pes"] if pe["role"] == "application"]
        self.assertEqual(
            [(4, 1), (4, 2), (5, 1), (5, 2)],
            sorted(
                (pe["fabric"]["x"], pe["fabric"]["y"])
                for pe in application
            ),
        )
        self.assertEqual(
            [(0, 0), (0, 1), (1, 0), (1, 1)],
            sorted(
                (pe["logical"]["x"], pe["logical"]["y"])
                for pe in application
            ),
        )
        colors = {
            route["color"]
            for route in layout["route_configs"]
            if route["pe_role"] == "application"
        }
        self.assertTrue({8, 9, 10, 11}.issubset(colors))
        self.assertEqual([], layout["validation"]["errors"])

    def test_source_only_bundle_keeps_loaded_and_dynamic_counts_unknown(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            bundle = root / "kernels/Tiny/CSL"
            bundle.mkdir(parents=True)
            (bundle / "commands_wse3.sh").write_text(
                "cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 "
                "--fabric-offsets=4,1 --params=width:2,height:1 -o out\n",
                encoding="utf-8",
            )
            (bundle / "layout.csl").write_text(
                "param width: u16; param height: u16; layout {\n"
                "@set_rectangle(width, height);\n"
                "@set_tile_code(0, 0, \"pe.csl\", .{});\n}\n",
                encoding="utf-8",
            )
            (bundle / "pe.csl").write_text("fn main() void {}\n", encoding="utf-8")
            entry = {
                "name": "Tiny",
                "benchmark_dir": "kernels/Tiny",
                "cuda_path": "kernels/Tiny/CUDA/kernel.cu",
                "csl_dir": "kernels/Tiny/CSL",
                "target_relpath": "pe.csl",
                "commands_script": "commands_wse3.sh",
                "arch": "wse3",
                "sweep": {"ordinal": 0, "split": "test", "reference_cycles": None},
            }
            layout = build_kernel_inventory(entry, root)
        self.assertEqual("partial", layout["validation"]["status"])
        self.assertEqual(2, layout["counts"]["application_allocated"]["value"])
        self.assertEqual("inferred", layout["counts"]["application_allocated"]["evidence"])
        self.assertIsNone(layout["counts"]["application_loaded"]["value"])
        self.assertIsNone(layout["counts"]["dynamically_active"]["value"])
        self.assertEqual([], layout["pes"])

    def test_optional_cs_readelf_runner_enriches_banks_without_being_required(self) -> None:
        runner = _FakeReadelf()
        layout = build_kernel_inventory(
            "ReLU-1PE", REPO_ROOT, cs_readelf_runner=runner
        )
        app = next(pe for pe in layout["pes"] if pe["role"] == "application")
        self.assertTrue(runner.calls)
        self.assertEqual(5808, app["memory"]["program_bytes"])
        self.assertEqual([2, 3], app["memory"]["banks"])
        self.assertEqual("reported_by_cs_readelf", app["memory"]["bank_status"])
        self.assertEqual("user_buffer", app["objects"][0]["name"])

    def test_campaign_hash_json_and_svgs_are_deterministic(self) -> None:
        first = build_campaign_inventory(
            REPO_ROOT, only=["ParBroadcast-Scale", "ReLU-1PE"]
        )
        second = build_campaign_inventory(
            REPO_ROOT, only=["ReLU-1PE", "ParBroadcast-Scale"]
        )
        self.assertEqual(first["campaign_sha256"], second["campaign_sha256"])
        self.assertEqual(2, first["counts"]["parsed_compiled"])
        self.assertEqual(0, first["counts"]["campaign_qualified"])
        self.assertEqual(0, first["counts"]["complete"])
        json.dumps(first)

        layout = copy.deepcopy(first["kernels"]["ParBroadcast-Scale"])
        layout["kernel"]["name"] = "broadcast <A&B>"
        full = render_full_fabric_svg(layout)
        zoom = render_zoom_svg(layout)
        self.assertEqual(full, render_full_fabric_svg(layout))
        self.assertIn("broadcast &lt;A&amp;B&gt;", full)
        self.assertIn("marker-end=\"url(#route-arrow)\"", zoom)
        self.assertIn('width="762.0000"', full)
        self.assertIn("no trace-derived volume", full)
        self.assertIn("campaign evidence: unqualified", full)
        self.assertNotIn("<script", full.lower())

        layout["flow_overlay"] = {
            "links": [
                {
                    "from": {"x": 4, "y": 1},
                    "to": {"x": 5, "y": 1},
                    "direction": "EAST",
                    "observations": 12,
                    "median_delay_cycles": 2,
                    "nonzero_backpressure_samples": 1,
                    "evidence": "inferred",
                    "source": "test trace",
                }
            ],
            "pes": [
                {
                    "fabric": {"x": 4, "y": 1},
                    "event_observations": 17,
                    "evidence": "simulator",
                }
            ],
        }
        overlaid = render_zoom_svg(layout)
        self.assertIn("observed-path volume 12", overlaid)
        self.assertIn("trace hotspot: 17", overlaid)

        with tempfile.TemporaryDirectory() as directory:
            written = write_inventory(first, directory)
            campaign_path = Path(written["campaign"])
            self.assertTrue(campaign_path.is_file())
            self.assertEqual(
                first["campaign_sha256"],
                json.loads(campaign_path.read_text(encoding="utf-8"))["campaign_sha256"],
            )
            kernel_paths = written["kernels"]["ReLU-1PE"]
            self.assertTrue(Path(kernel_paths["layout"]).is_file())
            self.assertTrue(Path(kernel_paths["svg_full_fabric"]).is_file())
            self.assertTrue(Path(kernel_paths["svg_zoom"]).is_file())


if __name__ == "__main__":
    unittest.main()
