# Descending multiplicity-table experiment

Exact artifact: `partition-work/algorithm/descending/Submission.lean`, SHA-256
`a028ffcb0ccf8b3767ea4a8fa55e2688671f5d768c5ae57a2c7630561cad74e5`.
Pinned official checkout `940f0a2ead23ef70ab1387edabb347e629111edd`,
Lean 4.33.1, macOS arm64. Source unchanged during measurement.

Independent `lake build` passed. The complete official **local** evaluator
returned `accepted`: comparator and correctness axiom audit exited 0,
correctness replay finished, and every unseeded public case finished.

| Group | n | Target replay wall time (s) |
| --- | ---: | ---: |
| P1 | 14 | 0.071810916 |
| P1 | 18 | 0.145159833 |
| P2 | 22 | 0.247865750 |
| P2 | 26 | 0.404450625 |
| P3 | 32 | 0.761706750 |
| P3 | 36 | 1.039721625 |

Correctness replay: 0.071779291 s, verification only. Local computation total:
**2.670715499 s**, versus **2.280962626 s** for the previously integrated
ascending multiplicity DP. The ascending total was lower by about 14.6% in
these single wall-time runs. This is diagnostic, not an official PMU comparison.

Reproduce from the workspace root:

```bash
python3 partition-work/evaluate.py \
  --submission partition-work/algorithm/descending/Submission.lean \
  --label descending \
  --tools-dir partition-work/tools \
  --evidence-dir partition-work/evidence
```

Raw logs and verdict:
`partition-work/evidence/descending-20260924T064857Z-a028ffcb0ccf/`.
