# Partition algorithm investigation

Pinned repository: `official/lean-kernel-challenge`, commit
`940f0a2ead23ef70ab1387edabb347e629111edd`.
Toolchain: `leanprover/lean4:v4.33.1`.

Read workspace `AGENTS.md`, `.agents/skills/lean-kernel-optimization/SKILL.md`,
the exact `problems/partition/Spec.lean`, starter and worked example,
`rules/overview.md`, `rules/problems/README.md`, `rules/problems/partition.md`,
`evaluation/README.md`, `evaluation/config.json`, and partition configuration.
The participant manifest has no packages. Partition has no separate dependency
lock file; it is a core Lean problem. No fixed files were modified.

## Candidate 1: exact multiplicity row table

For fixed maximum argument N, row k contains `partAux k m` for 0 <= m <= N.
Initialize with 1 at zero and 0 elsewhere. Compute the next row using exactly
the multiplicity sum in the specification, looking up its terms in the prior
row. This leaves the substantive mathematical recurrence unchanged.

Interface in `Submission.lean`:

```
lookup (xs : List Nat) (m : Nat) : Nat
row (k N : Nat) : List Nat
row_length (k N : Nat) : (row k N).length = N + 1
row_correct (k N m : Nat) (h : m <= N) :
  lookup (row k N) m = partAux k m
impl (n : Nat) := lookup (row n n) n
```

Proof invariant: table length is N+1 and every in-bounds entry has the stated
value. The induction step uses only `m - j * (k+1) <= m <= N` and congruence of
the existing list map and sum. No division lemma is needed.

Abstract arithmetic count for the fully materialized table is
`sum(k=1..N, m=0..N, floor(m/k)+1) = O(N^2 log N)` additions. This is NOT a
kernel complexity result: List lookup can traverse O(N) nodes, weak reduction
does not eagerly materialize rows, and sharing depends on the evaluator.
Integer additions operate on growing partition counts, so operation count is
also distinct from bit complexity.

Pinned library evidence favors lists over native-looking arrays for this
first implementation: `Init/Prelude.lean:3198` defines Array with a `toList`
field; `Array.getInternal` reduces to list access, and `Array.push` reduces to
`List.concat`. `Init/Data/Array/Basic.lean:331` builds `Array.ofFn` through
repeated push. Native compiled array bounds therefore do not transfer to the
kernel.

Possible representation refinement: store entries descending, look up argument
m at index N-m. The final query and many repeated largest-argument queries then
hit the head. Its proof needs only `Nat.sub_sub_self` and existing bounds. This
has not been adopted without measuring the first representation.

## Candidate 2: coin recurrence

Prove `partAux (k+1) (n+(k+1)) = partAux k (n+(k+1)) + partAux (k+1) n`
by splitting the multiplicity sum into j=0 and successor indices. Then build
each row left-to-right, adding the previous-row value to the already computed
current-row value at m-(k+1). A reverse accumulator places that current-row
value at index k. Out-of-bounds lookup handles m<k+1 by returning zero.

This reduces the abstract addition count to O(N^2), with O(N^3) potential list
traversal. The proof additionally needs quotient shifting and subtraction
cancellation for the recurrence, followed by a reverse-prefix table invariant.
The proof agent investigates this independently. It is the next candidate if
the exact-recurrence table has a measured bottleneck.

## Discriminating measurements

After the coordinator releases the exclusive baseline measurement hold,
compile the candidate with the pinned toolchain, audit axioms, and compare
direct kernel reduction/replay at n=18 and n=36. Reject any speed hypothesis
that these timings do not support. Then run the full public input plan
14,18,22,26,32,36 sequentially with the same evaluator and host.

Python recurrence-call accounting (not kernel timing) gives:

| n | naive recursive calls | full-table multiplicity summands |
|---:|---:|---:|
| 14 | 813 | 479 |
| 18 | 2398 | 816 |
| 22 | 6445 | 1250 |
| 26 | 16165 | 1784 |
| 32 | 57988 | 2780 |
| 36 | 128553 | 3577 |

Command used:

```sh
python3 - <<'PY'
from functools import lru_cache
@lru_cache(None)
def calls(k,n):
    return 1 if k == 0 else 1 + sum(calls(k-1,n-j*k) for j in range(n//k+1))
for n in (14,18,22,26,32,36):
    terms=sum(m//k+1 for k in range(1,n+1) for m in range(n+1))
    print(n, calls(n,n), terms)
PY
```

Compilation, axiom audit, correctness acceptance, and performance are separate
checks. After the coordinator released the baseline hold, the first candidate
compiled on its first attempt with exit code 0 and no diagnostics (compiler
command wall time 0.125 seconds; this is NOT a performance measurement):

```sh
LEAN_PATH=/Users/maltepetersen/Documents/ChatGPT/Lean-Coding-Session/official/lean-kernel-challenge/problems/partition/.lake/build/lib/lean \
  /Users/maltepetersen/.elan/toolchains/leanprover--lean4---v4.33.1/bin/lean \
  -DautoImplicit=false -DwarningAsError=true partition-work/algorithm/Submission.lean
```

Compiled candidate SHA256:
`53f902a8b614265c70d14afbfd04e3cc40fce2d6948efa6790ecdb6be6af4149`.
This verifies `row_length`, `row_correct`, and the universal `impl_correct`.
Axiom audit, evaluator acceptance, and performance remain the coordinator's
separate next steps. No benchmarks were run by the algorithm agent.
