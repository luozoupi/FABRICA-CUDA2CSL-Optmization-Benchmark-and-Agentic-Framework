"""Tests for extract_multi_file_blocks and extract_code_block's
multi-file compatibility (Piece 3b).
"""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from workflow_common import (  # type: ignore
    extract_code_block, extract_multi_file_blocks,
)


class MultiFileExtractorTests(unittest.TestCase):

    def test_two_focus_files_extracted(self) -> None:
        reply = (
            "Here are the updates:\n\n"
            "```csl:pe.csl\n"
            "fn run() void { blas.gemv(); }\n"
            "```\n\n"
            "```csl:src/blas.csl\n"
            "fn gemv() void { /* bulk fmacs */ }\n"
            "```\n"
        )
        out = extract_multi_file_blocks(reply)
        self.assertEqual(set(out.keys()), {"pe.csl", "src/blas.csl"})
        self.assertIn("blas.gemv()", out["pe.csl"])
        self.assertIn("bulk fmacs", out["src/blas.csl"])

    def test_legacy_single_fence_maps_to_empty_key(self) -> None:
        """A reply with the old ``` csl (no :relpath) fence still
        parses, mapping to the empty-string key so the caller can detect
        and fall back to the single-file path."""
        reply = "```csl\nfn x() void {}\n```\n"
        out = extract_multi_file_blocks(reply)
        self.assertEqual(set(out.keys()), {""})
        self.assertIn("fn x()", out[""])

    def test_mixed_fences_both_extracted(self) -> None:
        """Reply with both a legacy fence and a relpath fence — the
        parser keeps both."""
        reply = (
            "```csl\nold style body\n```\n\n"
            "```csl:src/blas.csl\nnew style body\n```\n"
        )
        out = extract_multi_file_blocks(reply)
        self.assertEqual(set(out.keys()), {"", "src/blas.csl"})

    def test_extract_code_block_still_handles_multifile_first_fence(self) -> None:
        """extract_code_block (legacy) must still return SOMETHING when
        the LLM only emits the new per-relpath fence form. Returns the
        first matching fence's body — single-file callers can keep
        working when the planner picked only one focus file even though
        the multi-file prompt was used."""
        reply = "```csl:pe.csl\nbody A\n```\n```csl:src/blas.csl\nbody B\n```"
        got = extract_code_block(reply, "csl")
        self.assertEqual(got, "body A")

    def test_no_fence_returns_empty(self) -> None:
        self.assertEqual(extract_multi_file_blocks(""), {})
        self.assertEqual(extract_multi_file_blocks("just prose"), {})

    def test_repeated_relpath_last_wins(self) -> None:
        """If the LLM emits two fences for the same relpath (draft +
        final), keep the LAST one — closer to "the LLM's final answer"."""
        reply = (
            "```csl:pe.csl\ndraft body\n```\n\n"
            "Actually let me redo that:\n\n"
            "```csl:pe.csl\nfinal body\n```\n"
        )
        out = extract_multi_file_blocks(reply)
        self.assertEqual(out["pe.csl"], "final body")

    def test_whitespace_relpath_stripped(self) -> None:
        """Tolerate stray whitespace around the relpath token."""
        reply = "```csl:src/blas.csl  \nbody\n```\n"
        out = extract_multi_file_blocks(reply)
        self.assertEqual(set(out.keys()), {"src/blas.csl"})

    def test_extract_code_block_legacy_still_works(self) -> None:
        """The pre-3b single-file callers must keep working."""
        reply = "```csl\nfn x() void {}\n```"
        self.assertEqual(extract_code_block(reply, "csl"),
                         "fn x() void {}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
