# Final partition evaluation evidence

Exact final artifact: `partition/Submission.lean`, SHA-256
`0fe392094beb40ce1672defec11443d58a5466605ebc0e283b39cf7cd752f575`.
The file remained byte-identical throughout the final evaluator and independent
smoke checks. Official checkout revision:
`940f0a2ead23ef70ab1387edabb347e629111edd`; toolchain:
`leanprover/lean4:v4.33.1`. The local host was macOS 27.0 arm64.

The disposable official participant package built successfully. The pinned
official **local** evaluator returned `accepted`: comparator exit 0, correctness
export axiom audit exit 0, full universal-proof correctness replay `ok`, and all
six unseeded public cases `ok`. The correctness replay took 0.341156125 s and
is verification only.

| Group | n | Refreshed baseline wall time (s) | Final wall time (s) |
| --- | ---: | ---: | ---: |
| P1 | 14 | 0.073596125 | 0.021870834 |
| P1 | 18 | 0.235924458 | 0.036789083 |
| P2 | 22 | 0.765234000 | 0.062124791 |
| P2 | 26 | 1.966541458 | 0.097244333 |
| P3 | 32 | 8.482210416 | 0.163193750 |
| P3 | 36 | 19.390456250 | 0.219776500 |

Both runs completed the full local plan. The computation replay sums were
30.913962707 s for the refreshed baseline and 0.600999291 s for the final
artifact, a 51.44× ratio **for these two wall-time runs**. An earlier baseline
run was 26.256420206 s; the difference illustrates local measurement variation.
The final source was also evaluated before integration at a different path,
yielding 0.636535499 s with the same bytes. These diagnostic single-replay
wall times do not give an official ranking, which requires Linux PMU instruction
counts with three replays per hidden case and the official resource envelope.

An independent `Smoke.lean` check imported the exact compiled artifact in a
temporary official participant package. `lake build` and
`lake env lean Smoke.lean` both exited 0. Lean printed the required type
`∀ (n : Nat), Submission.impl n = partitionSpec n` and the actual axiom list
`[propext, Quot.sound]`, which is within the pinned permitted set
`[propext, Quot.sound, Classical.choice]`. Kernel-reduced examples for inputs
0, 1, 4, 5, and 10 compiled using `rfl`.

Fixed-file checksums retained during the smoke run:

| File | SHA-256 |
| --- | --- |
| Official participant `Spec.lean` (identical to evaluator `Spec.lean`) | `035cf32a1b9001023a57726cb9ebe622165455d80443ad8d3590b50aa8360368` |
| Official participant `lakefile.toml` | `abe5aab760e8d1b36742f592a30490e9223e7e5357118e17a6385b8c2dd93cb0` |
| Official participant `lean-toolchain` | `3aac669c7a910ec2389f4e4f921b605adf6ebf2d1e0c9b9cd0be4d33f3f5db71` |
| Official evaluator `evaluation/run.py` | `234b5f15424af24217d86bbe72f373db5c6aa9210376f2b555aa3f074d191d88` |
| Official partition evaluator `config.json` | `a5b35df13a388556427b6b41bf6ffeecd93325cfd19631128877d703de4e7fe4` |

Reproduce serially from the workspace root after installing the documented
prerequisites (`elan`, Python, Git, C/C++ toolchain, and GNU coreutils on macOS):

```bash
bash partition-work/setup.sh
python3 partition-work/evaluate.py \
  --submission partition-work/baseline/Submission.lean \
  --label baseline-refresh \
  --tools-dir partition-work/tools \
  --evidence-dir partition-work/evidence
python3 partition-work/evaluate.py \
  --submission partition/Submission.lean \
  --label final \
  --tools-dir partition-work/tools \
  --evidence-dir partition-work/evidence
python3 partition-work/evidence/final-20260924T065307Z-0fe392094beb/smoke.py
```

The smoke script creates a temporary package by copying the three locked
participant files, the exact final `Submission.lean`, and
`partition-work/checks/Smoke.lean`; inside it runs `lake build` then
`lake env lean Smoke.lean`. It stores `smoke-build.log`, `smoke-lean.log`, and
`smoke-result.json` beside itself. Its temporary package is deleted afterward.

Raw final evaluator evidence is in
`partition-work/evidence/final-20260924T065307Z-0fe392094beb/`, including
`metadata.json`, `build.log`, `evaluation.log`, `verdict.json`, and
`summary.json`. Refreshed baseline evidence is in
`partition-work/evidence/baseline-refresh-20260924T065119Z-19cf636245f1/`.
