import Submission

#check (Submission.impl_correct : ∀ n, Submission.impl n = partitionSpec n)
#print axioms Submission.impl_correct

-- Published examples and the empty-partition boundary, reduced by the kernel.
example : Submission.impl 0 = 1 := rfl
example : Submission.impl 1 = 1 := rfl
example : Submission.impl 4 = 5 := rfl
example : Submission.impl 5 = 7 := rfl
example : Submission.impl 10 = 42 := rfl
