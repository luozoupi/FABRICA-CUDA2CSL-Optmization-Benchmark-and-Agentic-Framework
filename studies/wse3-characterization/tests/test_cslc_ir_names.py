"""Prevent routing/application IR artifacts overwriting each other."""
import re
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from cslc_ir import capture_program_name


class CaptureNames(unittest.TestCase):
    def test_preserves_existing_in_tree_names(self):
        cwd = Path('/work/source')
        self.assertEqual(capture_program_name(cwd / 'out/bin/out_0_0.elf', cwd), 'out_out_0_0')
        self.assertEqual(capture_program_name(cwd / 'out/east/bin/out_0_0.elf', cwd), 'out_east_out_0_0')

    def test_external_shadow_keeps_all_three_programs(self):
        cwd = Path('/work/source')
        paths = [Path('/captures/shadow') / role / 'bin/out_0_0.elf' for role in ('', 'east', 'west')]
        artifacts = {capture_program_name(path, cwd): str(path) for path in paths}
        self.assertEqual(len(artifacts), 3)
        self.assertEqual(set(artifacts.values()), set(map(str, paths)))

    def test_external_names_are_stable_and_filesystem_safe(self):
        path = Path('/captures/run with spaces/shadow/bin/out_0_0.elf')
        name = capture_program_name(path, Path('/work/source'))
        self.assertEqual(name, capture_program_name(path, Path('/work/source')))
        self.assertRegex(name, re.compile(r'^[A-Za-z0-9_.-]+$'))
        self.assertNotEqual(name, capture_program_name(Path('/another/shadow/bin/out_0_0.elf'), Path('/work/source')))


if __name__ == '__main__':
    unittest.main()
