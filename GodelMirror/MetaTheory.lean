-- Contains the mechanized proofs of the core meta-theoretical properties.
import GodelMirror.Semantics

open MirrorSystem

-- We can also prove the individual steps as theorems.

theorem paradox_leads_to_cap (t : MirrorSystem) (h : is_paradox t = true) :
    step t = cap t := by
  unfold step classify
  simp only [h, if_true]

theorem cap_leads_to_enter (t : MirrorSystem) (h : is_paradox t = true) :
    step (cap t) = enter (cap t) := by
  have h_integrate : is_integrate (cap t) = true := by
    unfold is_integrate integrate
    exact h
  unfold step classify is_paradox
  simp only [paradox_cap, Bool.false_eq_true, if_false, h_integrate, if_true]

theorem enter_leads_to_node (t : MirrorSystem) :
    step (enter (cap t)) = node (enter (cap t)) := by
  unfold step classify is_paradox
  simp only [paradox, Bool.false_eq_true, if_false, is_integrate_def, integrate, valid_reentry_enter_cap, if_true]

-- Theorem 1 (from paper): Controlled Reaction to Paradox
-- A paradoxical term deterministically reduces to a stable node in 3 steps.
theorem controlled_reaction_to_paradox (t : MirrorSystem) (h : is_paradox t = true) :
    run t 3 = node (enter (cap t)) := by
  have step1 := paradox_leads_to_cap t h
  have step2 := cap_leads_to_enter t h
  have step3 := enter_leads_to_node t
  simp only [run_succ, run_zero]
  rw [step1, step2, step3]

-- Chain theorem: paradox → cap → enter → node (the complete cycle)
theorem paradox_spiral (ms : MirrorSystem) (h : is_paradox ms = true) :
    run ms 3 = node (enter (cap ms)) := by
  exact controlled_reaction_to_paradox ms h

-- Helper: define what a value is
def is_value : MirrorSystem → Bool
| base => true
| _ => false

-- Theorem 5.1: Progress (simplified version)
-- Every term is either a value or can take a step to a term
theorem progress (t : MirrorSystem) :
    is_value t = true ∨ ∃ t', step t = t' := by
  cases t <;> try (left; rfl)
  all_goals (right; refine ⟨step _, rfl⟩)

-- Theorem 5.2: Label Preservation
-- Labels are preserved through reduction steps
theorem label_preservation (s : String) (t t' : MirrorSystem) :
    step (named s t) = named s t' → step t = t' := by
  intro h
  unfold step classify at h
  unfold step classify
  -- The classify function on (named s t) delegates to classify t
  -- So step (named s t) applies the same transformation as step t, wrapped in named s
  split at h <;> split
  · cases h  -- Both Paradox: cap (named s t) = named s t' → cap t = t'
  · unfold is_paradox is_integrate at *; simp at *  -- Paradox vs Integrate - contradiction
  · unfold is_paradox valid_reentry at *; simp at *  -- Paradox vs Reentry - contradiction
  · unfold is_paradox at *; simp at *  -- Paradox vs Normal - contradiction
  · unfold is_paradox is_integrate at *; simp at *  -- Integrate vs Paradox - contradiction
  · cases h  -- Both Integrate: enter (named s t) = named s t' → enter t = t'
  · unfold is_integrate valid_reentry at *; simp at *  -- Integrate vs Reentry - contradiction
  · unfold is_integrate at *; simp at *  -- Integrate vs Normal - contradiction
  · unfold is_paradox valid_reentry at *; simp at *  -- Reentry vs Paradox - contradiction
  · unfold is_integrate valid_reentry at *; simp at *  -- Reentry vs Integrate - contradiction
  · cases h  -- Both Reentry: node (named s t) = named s t' → node t = t'
  · unfold valid_reentry at *; simp at *  -- Reentry vs Normal - contradiction
  · unfold is_paradox at *; simp at *  -- Normal vs Paradox - contradiction
  · unfold is_integrate at *; simp at *  -- Normal vs Integrate - contradiction
  · unfold valid_reentry at *; simp at *  -- Normal vs Reentry - contradiction
  · cases h  -- Both Normal: node (named s t) = named s t' → node t = t'

/-
  NOTE: Completion and Weak Normalization (Section 6 of paper)

  These theorems are OMITTED from the workshop build because they require
  proving properties of partial recursive functions, which is problematic in Lean 4.
  The current implementation uses a partial function `completeFuel` with a fuel parameter
  to demonstrate the idea, but this is not suitable for formal proofs.

  For the LMCS journal version, these should be reformulated using an inductive
  relation for completion instead of a partial function.

  Key theorems to prove in the relational formulation:
  - Weak normalization for stratified terms
  - Confluence of completion steps
  - Canonical form uniqueness

  The current workshop demo uses completeFuel for #eval demonstrations only.
-/
