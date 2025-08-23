-- Contains the mechanized proofs of the core meta-theoretical properties.
import GodelMirror.Semantics

open MirrorSystem

-- Theorem 1 (from paper): Controlled Reaction to Paradox
-- A paradoxical term deterministically reduces to a stable node in 3 steps.
theorem controlled_reaction_to_paradox (t : MirrorSystem) (h : is_paradox t = true) :
    run t 3 = node (enter (cap t)) := by
  simp [run, step, classify, is_paradox, is_integrate, integrate, valid_reentry, h]

-- We can also prove the individual steps as lemmas.

lemma paradox_leads_to_cap (t : MirrorSystem) (h : is_paradox t = true) :
    step t = cap t := by
  simp [step, classify, is_paradox, h]

lemma cap_leads_to_enter (t : MirrorSystem) (h : is_paradox t = true) :
    step (cap t) = enter (cap t) := by
  have h_integrate : is_integrate (cap t) = true := by
    simp [is_integrate, integrate, is_paradox, h]
  simp [step, classify, is_paradox, h_integrate]

lemma enter_leads_to_node (t : MirrorSystem) :
    step (enter (cap t)) = node (enter (cap t)) := by
  have h_valid : valid_reentry (enter (cap t)) = true := by
    simp [valid_reentry]
  simp [step, classify, is_paradox, is_integrate, h_valid]

-- Chain theorem: paradox → cap → enter → node (the complete cycle)
theorem paradox_spiral (ms : MirrorSystem) (h : is_paradox ms = true) :
    run ms 3 = node (enter (cap ms)) := by
  controlled_reaction_to_paradox ms h