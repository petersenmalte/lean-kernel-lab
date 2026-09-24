import Spec

namespace Submission

/-- Total lookup; the table invariant ensures algorithmic accesses are in bounds. -/
def lookup (xs : List Nat) (i : Nat) : Nat := xs[i]?.getD 0

/-- Entry `i` stores the count for argument `N - i`. -/
def row : Nat → Nat → List Nat
  | 0, N => (List.range (N + 1)).map (fun i => match N - i with
      | 0 => 1
      | _ + 1 => 0)
  | k + 1, N =>
      let previous := row k N
      (List.range (N + 1)).map (fun i =>
        let m := N - i
        ((List.range (m / (k + 1) + 1)).map
          (fun j => lookup previous (N - (m - j * (k + 1))))).foldl (· + ·) 0)

theorem row_length (k N : Nat) : (row k N).length = N + 1 := by
  cases k <;> simp [row]

theorem lookup_map_range (f : Nat → Nat) (N i : Nat) (h : i ≤ N) :
    lookup ((List.range (N + 1)).map f) i = f i := by
  unfold lookup
  rw [List.getElem?_map, List.getElem?_range (Nat.lt_succ_of_le h)]
  rfl

/-- Descending indexing preserves the exact multiplicity recurrence. -/
theorem row_correct (k N m : Nat) (h : m ≤ N) :
    lookup (row k N) (N - m) = partAux k m := by
  induction k generalizing m with
  | zero =>
      rw [row, lookup_map_range _ _ _ (Nat.sub_le _ _), Nat.sub_sub_self h]
      cases m <;> rfl
  | succ k ih =>
      rw [row, lookup_map_range _ _ _ (Nat.sub_le _ _), Nat.sub_sub_self h]
      simp only [partAux]
      apply congrArg (fun xs : List Nat => xs.foldl (· + ·) 0)
      apply List.map_congr_left
      intro j _
      exact ih _ (Nat.le_trans (Nat.sub_le _ _) h)

def impl (n : Nat) : Nat := lookup (row n n) 0

theorem impl_correct : ∀ n, impl n = partitionSpec n := by
  intro n
  simpa [impl, partitionSpec] using row_correct n n n (Nat.le_refl n)

end Submission
