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

end Submission
