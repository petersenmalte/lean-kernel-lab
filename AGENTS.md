# Lean Kernel Challenge workspace

This workspace targets SAIR Lean Kernel Challenge Stage 1: optimize verified computations under the fixed evaluator, not the Lean kernel itself.

## Scope and sources
- Follow the user's current phase: research, setup, implementation, or evaluation. Setup/research does not authorize starting a competition implementation or submitting an entry.
- Before implementation, read the selected problem's Spec.lean, starter, worked example, dependency lock, and current rules in the official repository. Record the repository commit and Lean toolchain; do not silently upgrade them.
- Official source: https://github.com/SAIRcompetition/lean-kernel-challenge . Its pinned rules and evaluator take precedence over summaries here.
- Preserve fixed specifications and evaluator files. Submit only the permitted Submission.lean, with all required helpers included and only locked imports.
- Require a total kernel-reducible implementation and a universal correctness proof. No sorry/admit, native_decide, unsafe/partial implementations, additional axioms, encoded answers, or evaluator manipulation. Allowed proof axioms are currently propext, Quot.sound, Classical.choice; verify against the pinned rules.

## Multi-agent work
For substantive Lean challenge work, delegate bounded independent investigations or proof obligations when useful. Keep dependent steps local. Use at most three subagents, normally two; do not recursively delegate.
The main agent integrates changes and owns the final Submission.lean. Assign each worker exact writable files or an isolated candidate directory, a fixed interface, and an acceptance criterion. Shared filesystem access is not isolation. Never have workers edit the same file concurrently.
Use these local skills as relevant; read their SKILL.md even if not yet exposed by discovery:
- .agents/skills/lean-challenge-coordinator/SKILL.md
- .agents/skills/lean-kernel-optimization/SKILL.md
- .agents/skills/lean-proof-development/SKILL.md
- .agents/skills/lean-challenge-evaluation/SKILL.md
Custom roles are defined in .codex/agents/. If custom roles are unavailable, pass the corresponding role instructions and skill path to a normal subagent. Inherit the parent model unless the user or applicable runtime permits the configured override; report fallback rather than pretending a requested model ran.

## Evidence
- Compile with the pinned Lean toolchain; inspect actual compiler output rather than treating plausible proof text as verified.
- Separate compilation, axiom audit, evaluator acceptance, and performance results.
- Benchmark one candidate at a time on the same idle host. No parallel heavy builds during measured runs.
- Record revision, candidate checksum, commands, metric, per-case outcomes, and resource failures. Local wall time is not an official instruction-count ranking.
- Stop a failed approach at the agreed experiment budget and return the exact obstacle, not repeated equivalent retries.
- Never publish or submit externally unless the user requests that action.
