# Third-party provenance

FABRICA is a renamed, reduced source distribution of the xkernel codebase.
The original [BSD 3-Clause copyright and license](LICENSE) is retained unchanged.

Several reference kernels and shared CSL libraries derive from the
[Cerebras csl-examples](https://github.com/Cerebras/csl-examples) collection. Retain
all embedded copyright and license headers when redistributing these files.
A copy of the Apache 2.0 license is in [LICENSES/Apache-2.0.txt](LICENSES/Apache-2.0.txt).
`kernels/MC-Particle-Transport/LICENSE` is preserved with that benchmark.

The knowledge corpus includes public Cerebras SDK release notes, CSL tutorial
chunks, and skill material. Per-chunk `source_url` / `source_rst_url` fields and
manifests retain the source identities. Original upstream terms continue to apply;
the project license does not replace third-party notices.

Cerebras SDK binaries, container images, credentials, and raw experiment logs are
not part of this distribution.
