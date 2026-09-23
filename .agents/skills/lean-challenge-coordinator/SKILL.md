---
name: lean-challenge-coordinator
description: Coordinate bounded multi-agent research, implementation, and verification for SAIR Lean Kernel Challenge submissions.
---

Read the workspace AGENTS.md and preserve the user's current phase. Research-only work returns hypotheses and proof plans, without candidate implementation.

Before assigning work, locate the official checkout, record its revision and chosen problem, and read the locked interface and evaluator guide. If absent, acquiring the repository belongs to an authorized preparation phase; do not invent paths or results.

Choose at most two independent investigations initially: algorithm/representation research and proof feasibility. A third evaluator worker is useful only when it has independent work. Do not spawn a worker simply to fill a slot.

Give each worker:
- Problem and repository revision; paths to exact specification and relevant skill.
- Bounded question or proof obligation with fixed declaration names and types.
- Writable files or explicit read-only scope, plus an experiment/retry budget.
- Expected evidence: cited definitions, compiled lemmas if implementation is authorized, or measurements with commands.

The algorithm worker should expose its invariant before the proof worker depends on a new implementation. Integrate only after confirming interfaces match. Keep one owner for the final submission; worker helper files must be folded into that single file before final validation.

Compare candidates using measured kernel costs, proof feasibility, and all-case completion. Keep the last fully validated candidate when an experiment fails. Ask the evaluator worker for a final replay of the exact integrated artifact, not an earlier candidate.

Report what is proved, what is measured, what remains conjectural, and the next discriminating experiment. External submission is a separate user-authorized action.
