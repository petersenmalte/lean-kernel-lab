# Partition multiplicity DP, pinned local evaluator

The exact tested artifact is `partition/Submission.lean`, SHA-256
`53f902a8b614265c70d14afbfd04e3cc40fce2d6948efa6790ecdb6be6af4149`.
The source was unchanged throughout the run. The pinned official checkout was
`940f0a2ead23ef70ab1387edabb347e629111edd`, Lean toolchain
`leanprover/lean4:v4.33.1`, on macOS arm64. Tool revisions and fixed-file
checksums are in `multiplicity-dp-20260924T064536Z-53f902a8b614/metadata.json`.

The independent participant-package `lake build` passed. The official local
evaluator returned `accepted`: comparator and correctness-export axiom audit
both exited 0, the universal-proof correctness replay finished, and every
case in the public endpoint plan finished. Correctness replay was 0.076079875 s
and is verification only.

| Group | n | Baseline wall time (s) | Candidate wall time (s) | Candidate result |
| --- | ---: | ---: | ---: | --- |
| P1 | 14 | 0.071729000 | 0.068045375 | ok |
| P1 | 18 | 0.262259333 | 0.129658167 | ok |
| P2 | 22 | 0.796150166 | 0.214023417 | ok |
| P2 | 26 | 2.136997500 | 0.342631875 | ok |
| P3 | 32 | 11.100108291 | 0.573299792 | ok |
| P3 | 36 | 11.889175916 | 0.953304000 | ok |

The complete-plan local computation totals were **26.256420206 s** for the
baseline and **2.280962626 s** for this candidate, an **11.51×** ratio in this
single local run. These totals sum target-declaration kernel replay times only.
The macOS evaluator uses one wall-time repetition per unseeded public endpoint;
official ranking uses three PMU instruction-count repetitions per hidden case
on a Linux host. This run does not establish an official score, enforce the
official 4 GiB memory cap, or cover the hidden cohort inputs.

Reproduce from the workspace root, after preparing the pinned tools under
`partition-work/tools`:

```bash
python3 partition-work/evaluate.py \
  --submission partition/Submission.lean \
  --label multiplicity-dp \
  --tools-dir partition-work/tools \
  --evidence-dir partition-work/evidence
```

Raw evidence is in
`partition-work/evidence/multiplicity-dp-20260924T064536Z-53f902a8b614/`:
`metadata.json`, `build.log`, `build.json`, `evaluation.log`,
`evaluation.json`, `verdict.json`, and `summary.json`. Baseline evidence is in
`baseline-20260923T201431Z-19cf636245f1/`; see `BASELINE.md`.
