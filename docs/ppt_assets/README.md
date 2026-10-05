# xkernel PPT Asset Pack

Generated from the newer result and insight documents under `docs/`.

## Figures

- `figures/model_pass_rates.*` -- cross-model capability gap across 11 models.
- `figures/ablation_and_stack.*` -- one-shot vs full-stack correctness and W2 speedups.
- `figures/hardware_validation.*` -- simulator vs real WSE-3 cycle comparison.
- `figures/profiler_feedback.*` -- trace profiler feedback improving Jacobi and Game-of-Life.
- `figures/profiler_bottleneck_playbook.*` -- profiler signal to bottleneck/action mapping.
- `figures/agentic_workflow.*` -- slide diagram for the CUDA-to-CSL agent loop.
- `figures/sdk210_porting_status.*` -- SDK 2.10 hardware-porting compatibility classes.

Each figure is emitted as `.png`, `.pdf`, and `.svg`. Use PNG for quick PowerPoint
insertion and SVG/PDF when you want vector editing.

## Tables

- `tables/cross_model_summary.md` / `.csv`
- `tables/ablation_summary.md` / `.csv`
- `tables/hardware_validation.md` / `.csv`
- `tables/profiler_feedback.md` / `.csv`
- `tables/profiler_bottleneck_playbook.md` / `.csv`
- `tables/slide_claims_with_caveats.md` / `.csv`

## Suggested Slide Order

1. Start with `agentic_workflow` to explain the system.
2. Use `ablation_and_stack` for why the agentic stack matters.
3. Use `model_pass_rates` for the CSL capability gap.
4. Use `hardware_validation` to show real WSE-3 validation.
5. Use `profiler_feedback` to motivate feedback-agent upgrades.
6. Use `profiler_bottleneck_playbook` to explain how profiler information becomes action.
7. Use `sdk210_porting_status` for the next engineering frontier.

## Caveats To Say Out Loud

- Full-sweep and 12-kernel probe rates have different denominators.
- One-shot ablation is whole-system, not component-wise attribution.
- Hardware correctness is validated, but several hardware cycle measurements are
  marked partial because of timer/readback interpretation.
- Multi-seed robustness is not yet complete enough for aggregate publication claims.
