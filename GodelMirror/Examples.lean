-- A runnable example demonstrating the paradox resolution cycle.
import GodelMirror.Semantics

open MirrorSystem

-- Helper functions for creating a readable trace of the execution.
def toString : MirrorSystem → String
| base => "📦 base"
| node m => s!"🔁 node({toString m})"
| self_ref => "🪞 self_ref"
| cap m => s!"🔥 cap({toString m})"
| enter m => s!"🌱 enter({toString m})"
| named n _ => s!"🏷 '{n}'" -- Only show the name for clarity

def run_trace (start : MirrorSystem) (steps : Nat) : List String :=
  let rec go (t : MirrorSystem) (n : Nat) (acc : List String) : List String :=
    match n with
    | 0 => (toString t) :: acc
    | Nat.succ k => go (step t) k ((toString t) :: acc)
  (go start steps []).reverse

def numbered_trace (trace : List String) : IO Unit :=
  trace.zipIdx.forM fun (s, i) => IO.println s!"Step {i}: {s}"

-- The canonical example of a paradoxical term.
def paradoxical_term := named "Liar" self_ref

-- Gödel's example from the original v1 code
def godel_example := named "Gödel" (node self_ref)

-- Execute the trace for 4 steps and print the output.
#eval numbered_trace (run_trace paradoxical_term 4)
-- Expected output:
-- Step 0: 🏷 'Liar'
-- Step 1: 🔥 cap(🏷 'Liar')
-- Step 2: 🌱 enter(🔥 cap(🏷 'Liar'))
-- Step 3: 🔁 node(🌱 enter(🔥 cap(🏷 'Liar')))

#eval numbered_trace (run_trace godel_example 4)
-- Expected output for Gödel example:
-- Step 0: 🏷 'Gödel'  
-- Step 1: 🔥 cap(🏷 'Gödel')
-- Step 2: 🌱 enter(🔥 cap(🏷 'Gödel'))
-- Step 3: 🔁 node(🌱 enter(🔥 cap(🏷 'Gödel')))

-- Additional examples demonstrating different starting points
def simple_paradox := self_ref

#eval numbered_trace (run_trace simple_paradox 4)