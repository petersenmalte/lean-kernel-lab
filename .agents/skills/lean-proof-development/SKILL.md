---
name: lean-proof-development
description: Develop and debug universally quantified Lean correctness proofs against the locked SAIR challenge specification.
---

Read AGENTS.md, Spec.lean, and allowed imports. Confirm declaration names and theorem types in the installed pinned sources using search and small compiler checks; do not invent Mathlib lemma names or assume Mathlib exists in a core-only problem.

Agree on the algorithm's interface before dependent proof work. Prefer a state invariant connecting the optimized representation to the spec, a transition lemma, and then an induction/iteration theorem. Cover zero, boundary indices, truncated Nat subtraction, decoded inputs, and representation bounds explicitly where relevant.

Use the pinned project's lake environment and short compilation iterations. For a failure, report the exact goal and relevant error; change the proof strategy when repeated tactic variations do not address it. Do not bypass missing proofs with axioms or sorry. State unresolved proof obligations in prose outside the candidate instead.

The implementation must actually kernel-reduce to its output. Assess termination machinery and dependent casts for reduction overhead; a total function that compiles is not by itself evidence of evaluator success.

Inspect #print axioms Submission.impl_correct in a separate audit file when useful, but rely on the official audit for acceptance. The theorem must have the exact universal statement, not a bounded or weakened replacement. Deliver proof files with commands and results, and list any remaining obligations honestly.
