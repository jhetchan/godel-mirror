-- A runnable example demonstrating the paradox resolution cycle.
import GodelMirror.Semantics

open MirrorSystem

-- Helper functions for creating a readable trace of the execution.
def toStringEmoji : MirrorSystem → String
| base => "📦 base"
| node m => s!"🔁 node({toStringEmoji m})"
| self_ref => "🪞 self_ref"
| cap m => s!"🔥 cap({toStringEmoji m})"
| enter m => s!"🌱 enter({toStringEmoji m})"
| named n _ => s!"🏷 '{n}'" -- Only show the name for clarity

def run_trace (start : MirrorSystem) (steps : Nat) : List String :=
  let rec go (t : MirrorSystem) (n : Nat) (acc : List String) : List String :=
    match n with
    | 0 => (toStringEmoji t) :: acc
    | Nat.succ k => go (step t) k ((toStringEmoji t) :: acc)
  (go start steps []).reverse

def numbered_trace (trace : List String) : IO Unit :=
  trace.zipIdx.forM fun (s, i) => IO.println s!"Step {i}: {s}"

-- The canonical example of a paradoxical term.
def paradoxical_term := named "Liar" self_ref

-- Gödel's example from the original v1 code
def godel_example := named "Gödel" (node self_ref)

-- Execute the trace for 4 steps and print the output.
#eval! numbered_trace (run_trace paradoxical_term 4)
-- Expected output:
-- Step 0: 🏷 'Liar'
-- Step 1: 🔥 cap(🏷 'Liar')
-- Step 2: 🌱 enter(🔥 cap(🏷 'Liar'))
-- Step 3: 🔁 node(🌱 enter(🔥 cap(🏷 'Liar')))

#eval! numbered_trace (run_trace godel_example 4)
-- Expected output for Gödel example:
-- Step 0: 🏷 'Gödel'
-- Step 1: 🔥 cap(🏷 'Gödel')
-- Step 2: 🌱 enter(🔥 cap(🏷 'Gödel'))
-- Step 3: 🔁 node(🌱 enter(🔥 cap(🏷 'Gödel')))

-- Additional examples demonstrating different starting points
def simple_paradox := self_ref

#eval! numbered_trace (run_trace simple_paradox 4)

-- Completion Examples (Section 6) - using fuel-based demo version

-- Helper: Full toString that shows structure
def toStringFull : MirrorSystem → String
| base => "base"
| node m => s!"node({toStringFull m})"
| self_ref => "self_ref"
| cap m => s!"cap({toStringFull m})"
| enter m => s!"enter({toStringFull m})"
| named n m => s!"named '{n}' ({toStringFull m})"

-- Example: Completion of a stratified paradoxical term
def example_before := named "Liar" self_ref
def example_after := completeFuel 5 example_before

#eval! IO.println "\n=== Completion Example (fuel=5) ==="
#eval! IO.println s!"Before: {toStringFull example_before}"
#eval! IO.println s!"After:  {toStringFull example_after}"
#eval! IO.println s!"Contains paradox (before): {contains_paradox example_before}"
#eval! IO.println s!"Contains paradox (after): {contains_paradox example_after}"

-- Example: Non-stratified term (nested paradox)
def nested_paradox := cap self_ref
def nested_completed := completeFuel 5 nested_paradox

#eval! IO.println "\n=== Nested Paradox Example (fuel=5) ==="
#eval! IO.println s!"Before: {toStringFull nested_paradox}"
#eval! IO.println s!"After:  {toStringFull nested_completed}"
#eval! IO.println s!"Contains paradox (before): {contains_paradox nested_paradox}"
#eval! IO.println s!"Contains paradox (after): {contains_paradox nested_completed}"

-- Example: Term that requires multiple resolution steps
def complex_term := cap (named "Nested" self_ref)
def complex_completed := completeFuel 10 complex_term

#eval! IO.println "\n=== Complex Nested Example (fuel=10) ==="
#eval! IO.println s!"Before: {toStringFull complex_term}"
#eval! IO.println s!"After:  {toStringFull complex_completed}"
#eval! IO.println s!"Contains paradox (before): {contains_paradox complex_term}"
#eval! IO.println s!"Contains paradox (after): {contains_paradox complex_completed}"
