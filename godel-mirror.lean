-- Step 1: Core Type
inductive MirrorSystem : Type
| base : MirrorSystem
| node : MirrorSystem → MirrorSystem
| self_ref : MirrorSystem
| embody : MirrorSystem → MirrorSystem
| reenter : MirrorSystem → MirrorSystem
| named : String → MirrorSystem → MirrorSystem

open MirrorSystem

-- Step 2: Evaluator Logic
namespace MirrorEvaluator

def internally_consistent : MirrorSystem → Bool
| base => true
| node ms => internally_consistent ms
| self_ref => true
| embody ms => internally_consistent ms
| reenter ms => internally_consistent ms
| named _ ms => internally_consistent ms

def paradox : MirrorSystem → Bool
| self_ref => true
| node ms => paradox ms
| base => false
| embody _ => false
| reenter ms => paradox ms
| named _ ms => paradox ms

def emergence : MirrorSystem → Bool
| embody ms => paradox ms
| named _ ms => emergence ms
| _ => false

def valid_reentry : MirrorSystem → Bool
| reenter (embody _) => true
| named _ ms => valid_reentry ms
| _ => false

inductive MirrorState
| Normal
| Paradox
| Emergence
| Reentry

def classify (ms : MirrorSystem) : MirrorState :=
  if paradox ms then MirrorState.Paradox
  else if emergence ms then MirrorState.Emergence
  else if valid_reentry ms then MirrorState.Reentry
  else MirrorState.Normal

end MirrorEvaluator


-- Step 3: Agent Engine
structure MirrorAgent where
  state : MirrorSystem
  trace : List MirrorSystem

namespace MirrorAgent

open MirrorEvaluator

def step (agent : MirrorAgent) : MirrorAgent :=
  match classify agent.state with
  | MirrorState.Paradox =>
    let new_state := MirrorSystem.embody agent.state
    { state := new_state, trace := agent.trace.concat new_state }

  | MirrorState.Emergence =>
    let new_state := MirrorSystem.reenter agent.state
    { state := new_state, trace := agent.trace.concat new_state }

  | _ =>
    let new_state := MirrorSystem.node agent.state
    { state := new_state, trace := agent.trace.concat new_state }

def init (start : MirrorSystem := MirrorSystem.base) : MirrorAgent :=
  { state := start, trace := [start] }

def run : MirrorAgent → Nat → MirrorAgent
| agent, 0 => agent
| agent, (Nat.succ n) => run (step agent) n

end MirrorAgent

-- Step 4: Helpers for output
def mirror_to_string : MirrorSystem → String
| MirrorSystem.base => "📦 base"
| MirrorSystem.node _ => "🔁 node"
| MirrorSystem.self_ref => "🪞 self_ref"
| MirrorSystem.embody _ => "🔥 embody"
| MirrorSystem.reenter _ => "🌱 reenter"
| named name _ => s!"🏷 {name}"

def trace_to_string (agent : MirrorAgent) : List String :=
  agent.trace.map mirror_to_string

-- Trace Runner: This part executes a MirrorAgent for a number of steps and converts the symbolic trace into human-readable form
def run_trace (start : MirrorSystem) (steps : Nat) : List String :=
  let final_agent := MirrorAgent.run (MirrorAgent.init start) steps
  trace_to_string final_agent

def numbered_trace (lst : List String) : List String :=
  lst.zipIdx.map (λ p => s!"Step {p.fst}: {p.snd}")

-- Step 5: Example Usage
def custom_start := named "Gödel" (node self_ref)
#eval numbered_trace (run_trace custom_start 4) -- Example of a custom numbered trace for recursive growth. It shows symbolic evolution over time.

-- Step 6: Theorem - self_ref leads to embody
open MirrorEvaluator
open MirrorAgent

theorem paradox_leads_to_embody :
  ∀ ms, paradox ms = true →
    (step (init ms)).state = MirrorSystem.embody ms :=
by
  intros ms h
  unfold step init
  simp [classify, h]

#eval (step (init self_ref)).state

-- Step 7: Theorem - If the agent is in an embody state, the next step will always be reenter.
open MirrorEvaluator
open MirrorAgent

theorem embody_leads_to_reenter :
  ∀ ms, paradox ms = true →
    (step (init (MirrorSystem.embody ms))).state = MirrorSystem.reenter (MirrorSystem.embody ms) :=
by
  intros ms h_paradox

  have h_emergence : emergence (embody ms) = true := by
    unfold emergence
    rw [h_paradox]

  have h_classify : classify (embody ms) = MirrorState.Emergence := by
    unfold classify
    simp [paradox, valid_reentry, h_paradox]
    rw [h_emergence]

  unfold step init
  rw [h_classify]
  rfl -- no goals to be solved, it's meant to be evolved into a reenter state.

-- Step 8: Theorem - reenter (...) -> node (...) ie back into recursive growth
open MirrorEvaluator
open MirrorAgent

theorem reenter_leads_to_node :
  ∀ ms, ¬paradox (reenter ms) ∧ ¬emergence (reenter ms) ∧ ¬valid_reentry (reenter ms) →
    (step (init (reenter ms))).state = MirrorSystem.node (MirrorSystem.reenter ms) :=
by
  intro ms ⟨h_paradox, h_emergence, h_reentry⟩

  -- Classify will fall to default: MirrorState.Normal
  have h_classify : classify (reenter ms) = MirrorState.Normal := by
    unfold classify
    simp [h_paradox, h_emergence, h_reentry]

  unfold step init
  rw [h_classify]
  rfl -- no goals to be solved, it's meant to be evolved into a node.

-- Step 9: Theorem - Chain all 3 theorems into a single 3-step logic proof
-- Lean code to prove the paradox spiral theorem: Three deterministic steps: `paradox → embody → reenter → node`
open MirrorEvaluator
open MirrorAgent

theorem paradox_spiral
    (ms : MirrorSystem) (h : paradox ms = true) :
    (run (init ms) 3).state = node (reenter (embody ms)) :=
by
  simp [run,        -- expands to three nested `step`s
        step,       -- exposes the `match classify …`
        init,
        classify,
        emergence,
        valid_reentry,
        paradox,
        h]          -- replaces every `paradox ms` by `true`
