# Partition baseline, pinned local evaluator

The baseline is the official starter copied to
`partition-work/baseline/Submission.lean`. Its SHA-256 is
`19cf636245f1fde66fac04ac82a88f728e9071056278eab0a1bcc11ad9b50305`.
The source was unchanged throughout the run.

- Official checkout: `940f0a2ead23ef70ab1387edabb347e629111edd`.
- Toolchain: `leanprover/lean4:v4.33.1`; installed Lean reports
  `4.33.1` commit `819816b2e0a3bf405af45ae5c7af2491d8f5bee6`.
- Tool revisions: comparator `3927ad383f208ae977c340a91c48ac9b497d2097`
  with the official export patch; lean4export
  `15f6055e299ad5b89345e533cc2192f4cc00f659`.
- Host: macOS 27.0, arm64. Metric: local `wall_time`, one repetition per case,
  unseeded public endpoint plan, default `--timeout 120`.

The independent `lake build` passed. The local official judge returned
`accepted`; comparator, correctness-export axiom audit, and correctness replay
all passed. Correctness replay was 0.039652375 s and is verification only.

| Group | n | Outcome | Target replay wall time (s) |
| --- | ---: | --- | ---: |
| P1 | 14 | ok | 0.071729000 |
| P1 | 18 | ok | 0.262259333 |
| P2 | 22 | ok | 0.796150166 |
| P2 | 26 | ok | 2.136997500 |
| P3 | 32 | ok | 11.100108291 |
| P3 | 36 | ok | 11.889175916 |

Local complete-plan computation total: **26.256420206 s**. This is a
diagnostic sum of wall-time measurements, not the official Linux PMU instruction
total or ranking. The local run does not enforce the official 4 GiB memory cap
or Linux isolation, and its unseeded inputs are not the hidden cohort.

Reproduce from the workspace root after preparing pinned tools in
`partition-work/tools`:

```bash
python3 partition-work/evaluate.py \
  --submission partition-work/baseline/Submission.lean \
  --label baseline \
  --tools-dir partition-work/tools \
  --evidence-dir partition-work/evidence
```

Raw evidence is in
`partition-work/evidence/baseline-20260923T201431Z-19cf636245f1/`:
`metadata.json`, `build.log`, `build.json`, `evaluation.log`,
`evaluation.json`, `verdict.json`, and `summary.json`. The evaluator took
156.422 s end to end; that duration includes checks and case preparation and
is distinct from the replay computation total.
