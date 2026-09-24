import Spec

namespace Submission

/-- The locked multiplicity sum, viewed as a right-associated natural sum. -/
theorem partAux_succ_sum (k n : Nat) :
    partAux (k + 1) n =
      ((List.range (n / (k + 1) + 1)).map
        (fun j => partAux k (n - j * (k + 1)))).sum := by
  rw [partAux, List.sum_eq_foldl_nat]

/-- Adding one largest part splits partitions into those using it and those not. -/
theorem partAux_add_part (k n : Nat) :
    partAux (k + 1) (n + (k + 1)) =
      partAux k (n + (k + 1)) + partAux (k + 1) n := by
  rw [partAux_succ_sum, Nat.add_div_right n (Nat.succ_pos k)]
  rw [List.range_succ_eq_map]
  simp only [List.map_cons, List.map_map, List.sum_cons,
    Nat.zero_mul, Nat.sub_zero]
  rw [partAux_succ_sum]
  apply congrArg (fun xs : List Nat => partAux k (n + (k + 1)) + xs.sum)
  apply List.map_congr_left
  intro j _
  simp only [Function.comp_apply, Nat.succ_mul, Nat.add_sub_add_right]

/-- Below the new part size, only multiplicity zero is possible. -/
theorem partAux_of_lt_part (k n : Nat) (h : n < k + 1) :
    partAux (k + 1) n = partAux k n := by
  rw [partAux_succ_sum, Nat.div_eq_of_lt h]
  simp

/-- Coin-change recurrence with the truncated subtraction boundary explicit. -/
theorem partAux_coin (k n : Nat) :
    partAux (k + 1) n =
      partAux k n + if k + 1 ≤ n then partAux (k + 1) (n - (k + 1)) else 0 := by
  by_cases h : k + 1 ≤ n
  · rw [if_pos h]
    have hn : n = (n - (k + 1)) + (k + 1) := (Nat.sub_add_cancel h).symm
    calc
      partAux (k + 1) n = partAux (k + 1) ((n - (k + 1)) + (k + 1)) :=
        congrArg (partAux (k + 1)) hn
      _ = partAux k ((n - (k + 1)) + (k + 1)) + partAux (k + 1) (n - (k + 1)) :=
        partAux_add_part k (n - (k + 1))
      _ = partAux k n + partAux (k + 1) (n - (k + 1)) := by rw [← hn]
  · rw [if_neg h, Nat.add_zero]
    exact partAux_of_lt_part k n (Nat.lt_of_not_ge h)

/-- Total list lookup; a missing predecessor contributes zero. -/
def lookup (xs : List Nat) (i : Nat) : Nat := xs[i]?.getD 0

/-- Process the previous row in ascending order, keeping the new prefix reversed. -/
def fill (k : Nat) : List Nat → List Nat → List Nat
  | [], acc => acc.reverse
  | x :: xs, acc => fill k xs ((x + lookup acc k) :: acc)

theorem fill_length (k : Nat) (xs acc : List Nat) :
    (fill k xs acc).length = xs.length + acc.length := by
  induction xs generalizing acc with
  | nil => simp [fill]
  | cons x xs ih =>
    simp only [fill, ih, List.length_cons]
    omega

/-- Reverse-prefix invariant: position i stores the value at length - 1 - i. -/
def PrefixCorrect (k : Nat) (acc : List Nat) : Prop :=
  ∀ i, i < acc.length → lookup acc i = partAux (k + 1) (acc.length - 1 - i)

theorem next_correct (k x : Nat) (acc : List Nat)
    (hp : PrefixCorrect k acc) (hx : x = partAux k acc.length) :
    x + lookup acc k = partAux (k + 1) acc.length := by
  rw [partAux_coin, ← hx]
  apply congrArg (fun a => x + a)
  by_cases h : k + 1 ≤ acc.length
  · rw [if_pos h, hp k (by omega)]
    congr 1
    omega
  · rw [if_neg h]
    unfold lookup
    rw [List.getElem?_eq_none (by omega)]
    rfl

theorem prefix_cons (k y : Nat) (acc : List Nat)
    (hp : PrefixCorrect k acc) (hy : y = partAux (k + 1) acc.length) :
    PrefixCorrect k (y :: acc) := by
  intro i hi
  cases i with
  | zero => simpa [lookup] using hy
  | succ i =>
    have hi' : i < acc.length := by simpa using hi
    have hidx : (y :: acc).length - 1 - (i + 1) = acc.length - 1 - i := by
      simp only [List.length_cons]
      omega
    simpa only [lookup, List.getElem?_cons_succ, hidx] using hp i hi'

/-- The remaining input is the suffix of the old row after the processed prefix. -/
theorem fill_correct (k : Nat) (xs acc : List Nat)
    (hp : PrefixCorrect k acc)
    (hs : ∀ i, i < xs.length → lookup xs i = partAux k (acc.length + i)) :
    ∀ i, i < xs.length + acc.length →
      lookup (fill k xs acc) i = partAux (k + 1) i := by
  induction xs generalizing acc with
  | nil =>
    intro i hi
    have hi' : i < acc.length := by simpa using hi
    have hj : acc.length - 1 - i < acc.length := by omega
    have hidx : acc.length - 1 - (acc.length - 1 - i) = i := by omega
    change (acc.reverse[i]?).getD 0 = _
    rw [List.getElem?_reverse hi']
    change lookup acc (acc.length - 1 - i) = _
    rw [hp _ hj, hidx]
  | cons x xs ih =>
    have hx : x = partAux k acc.length := by
      simpa [lookup] using hs 0 (by simp)
    have hy : x + lookup acc k = partAux (k + 1) acc.length :=
      next_correct k x acc hp hx
    have hp' : PrefixCorrect k ((x + lookup acc k) :: acc) :=
      prefix_cons k _ acc hp hy
    have hs' : ∀ i, i < xs.length → lookup xs i =
        partAux k (((x + lookup acc k) :: acc).length + i) := by
      intro i hi
      simpa [lookup, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using
        hs (i + 1) (by simpa using hi)
    intro i hi
    exact ih _ hp' hs' i (by simp only [List.length_cons] at hi ⊢; omega)

/-- Every row contains the values at arguments 0 through N. -/
def row : Nat → Nat → List Nat
  | 0, N => 1 :: List.replicate N 0
  | k + 1, N => fill k (row k N) []

theorem row_length (k N : Nat) : (row k N).length = N + 1 := by
  induction k with
  | zero => simp [row]
  | succ k ih => simpa [row, fill_length] using ih

theorem row_correct (k N i : Nat) (hi : i ≤ N) :
    lookup (row k N) i = partAux k i := by
  induction k generalizing i with
  | zero =>
    cases i with
    | zero => rfl
    | succ i =>
      simp only [row, lookup, List.getElem?_cons_succ,
        List.getElem?_replicate_of_lt (by omega : i < N)]
      rfl
  | succ k ih =>
    apply fill_correct k (row k N) []
    · intro j hj
      simp at hj
    · intro j hj
      have hj' : j ≤ N := by rw [row_length] at hj; omega
      simpa using ih j hj'
    · simpa [row_length] using Nat.lt_succ_of_le hi

def impl (n : Nat) : Nat := lookup (row n n) n

theorem impl_correct : ∀ n, impl n = partitionSpec n := by
  intro n
  exact row_correct n n n (Nat.le_refl n)

end Submission
