---
name: lean-challenge-evaluation
description: Run and interpret reproducible build, correctness, and kernel-performance checks for SAIR Lean Kernel Challenge candidates.
---

Read AGENTS.md plus evaluation/README.md and the chosen problem's current rules/configuration in the pinned official checkout. Follow their actual CLI; commands and budgets can change. Verify toolchain, dependencies, and platform support before expensive setup. Setup may reset managed tool checkouts, so use a dedicated tools directory according to the guide.

Keep these results separate:
1. Compilation and universal proof elaboration.
2. Required interface/binding and axiom checks plus correctness replay.
3. Every planned computation case with its resource outcome and metric.

lake build alone does not establish acceptance. Local wall-time runs are diagnostic, not official scores. Current official ranking uses the sum of per-case median instruction counts over three replays, with all checks and cases passing; confirm this in the pinned rules. Proof checking is a gate rather than a ranking component.

On macOS, do not claim Linux PMU instruction measurements from wall time. Check documented host requirements; record unsupported measurement as unavailable. Do not silently alter timeouts, memory, dependencies, seeds, or test plans to claim an official-equivalent pass.

Run performance experiments serially on the same host without competing builds. Preserve baseline and candidate outputs. For every comparison record checkout commit, Lean version, candidate SHA-256, exact command, host, metric, evaluator policy, each planned case's outcome, and total only if meaningful. Failed or unrun cases are not zero. Never mix cohorts or metrics.

For final validation, use the exact single-file artifact including all helpers and no extra imports. Report correctness failures separately from time/memory failures. Do not edit a candidate during its measurement or submit it externally.
