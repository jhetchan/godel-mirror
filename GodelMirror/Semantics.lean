-- Defines the operational semantics (the rewrite rules) of the Gödel Mirror.
import GodelMirror.Syntax

open MirrorSystem
open MirrorState

-- Predicate to identify if a term contains a paradox
def paradox : MirrorSystem → Bool
| self_ref => true
| node ms => paradox ms
| base => false
| cap _ => false
| enter ms => paradox ms
| named _ ms => paradox ms

-- Predicate to identify a term in a Paradox state.
def is_paradox (t : MirrorSystem) : Bool :=
  match t with
  | named _ self_ref => true
  | self_ref => true
  | _ => paradox t

-- Predicate to identify a term that has integrated a paradox (formerly emergence)
def integrate : MirrorSystem → Bool
| cap ms => is_paradox ms
| named _ ms => integrate ms
| _ => false

-- Predicate to identify a term in an Integrate state.
def is_integrate (t : MirrorSystem) : Bool :=
  integrate t

-- Predicate to identify valid reentry
def valid_reentry : MirrorSystem → Bool
| enter (cap _) => true
| named _ ms => valid_reentry ms
| _ => false

-- State classification function
def classify (ms : MirrorSystem) : MirrorState :=
  if is_paradox ms then MirrorState.Paradox
  else if is_integrate ms then MirrorState.Integrate
  else if valid_reentry ms then MirrorState.Reentry
  else MirrorState.Normal

-- Single-step reduction function. This defines the core rewrite rules.
def step (t : MirrorSystem) : MirrorSystem :=
  match classify t with
  | MirrorState.Paradox => cap t
  | MirrorState.Integrate => enter t
  | MirrorState.Reentry => node t
  | MirrorState.Normal => node t

-- Multi-step reduction function.
def run : MirrorSystem → Nat → MirrorSystem
| t, 0 => t
| t, (Nat.succ n) => run (step t) n

-- Simp lemmas for specific cases
@[simp] theorem is_paradox_self_ref : is_paradox self_ref = true := rfl
@[simp] theorem is_paradox_named_self_ref (n : String) : is_paradox (named n self_ref) = true := rfl
@[simp] theorem paradox_self_ref : paradox self_ref = true := rfl
@[simp] theorem paradox_base : paradox base = false := rfl
@[simp] theorem paradox_cap (t : MirrorSystem) : paradox (cap t) = false := rfl
@[simp] theorem integrate_cap (t : MirrorSystem) : integrate (cap t) = is_paradox t := rfl
@[simp] theorem is_integrate_def (t : MirrorSystem) : is_integrate t = integrate t := rfl
@[simp] theorem valid_reentry_enter_cap (t : MirrorSystem) : valid_reentry (enter (cap t)) = true := rfl
@[simp] theorem run_zero (t : MirrorSystem) : run t 0 = t := rfl
@[simp] theorem run_succ (t : MirrorSystem) (n : Nat) : run t (Nat.succ n) = run (step t) n := rfl
