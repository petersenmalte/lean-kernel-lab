---
name: lean-kernel-optimization
description: Investigate algorithms and representations that reduce Lean kernel computation cost for a fixed SAIR challenge specification.
---

Read AGENTS.md and the exact spec, test ranges, starter and worked example before proposing improvements. Optimize code evaluated by the fixed kernel; changing that kernel is outside Stage 1.

For each candidate identify mathematical work, representation cost, recursive unfolding, repeated subexpressions, and growing integer sizes. Native compiled performance, tail recursion, arrays, or let-bindings alone do not establish fast kernel reduction or sharing. Measure the actual evaluator path when authorized.

Prefer eliminating redundant computation before local syntax changes. Inspect the pinned kernel's supported primitive reductions before relying on bit operations or machine-number types. Distinguish arithmetic-operation complexity from bit complexity.

Suggested investigations, not assumed wins:
- Partitions: dynamic programming with an invariant equivalent to the fixed recurrence; compare kernel-friendly storage. Euler's pentagonal recurrence may require substantially more proof work and is not automatically the first choice.
- Permanent: exploit the generator's sparse rows, masks, and repeated subproblems; prove equivalence for every decoded input, including dimensions outside benchmarks.
- Rule 110: simplify the already supplied packed-bit implementation; bitpacking itself is already baseline work.
- Fibonacci: fast doubling already exists in the worked example; inspect reductions and arithmetic duplication before claiming novelty.

Return at most two promising candidates, the key invariant, expected bottleneck, and the smallest measurement that could reject the hypothesis. Do not precompute answers for test values. Without measurements, label predicted gains as hypotheses.
