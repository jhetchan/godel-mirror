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