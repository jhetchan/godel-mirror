-- Workshop demo: fuel-based evaluation with live traces
-- Does NOT import MetaTheory (avoids sorry axiom issues)
import GodelMirror.Semantics

open MirrorSystem

-- Add emoji representation for demo output (partial to handle cyclic structures)
partial def toStringEmoji : MirrorSystem → String
| base => "📦 base"
| node m => s!"🔁 node({toStringEmoji m})"
| self_ref => "🪞 self_ref"
| cap m => s!"🔥 cap({toStringEmoji m})"
| enter m => s!"🌱 enter({toStringEmoji m})"
| named n _ => s!"🏷 '{n}'" -- Only show the name for clarity

-- Helper to create trace of execution with emoji output
def run_trace (start : MirrorSystem) (steps : Nat) : List String :=
  let rec go (t : MirrorSystem) (n : Nat) (acc : List String) : List String :=
    match n with
    | 0 => (toStringEmoji t) :: acc
    | Nat.succ k => go (step t) k ((toStringEmoji t) :: acc)
  termination_by n
  (go start steps []).reverse

-- Pretty-print numbered trace
def numbered_trace (trace : List String) : IO Unit :=
  trace.zipIdx.forM fun (s, i) => IO.println s!"Step {i}: {s}"

-- The Liar paradox: "This statement is false"
def liar : MirrorSystem := named "Liar" self_ref

-- Demo 1: The classic Liar paradox
#eval! do
  IO.println "\n--- Paradox cycle: Liar (fuel = 3) ---"
  numbered_trace (run_trace liar 3)
  IO.println ""

-- Demo 2: Nested paradox
#eval! do
  IO.println "--- Nested paradox processes outer-first (fuel = 4) ---"
  let nested := named "Outer" (named "Inner" self_ref)
  numbered_trace (run_trace nested 4)
  IO.println ""

-- Demo 3: Simple self-reference
#eval! do
  IO.println "--- Simple self-ref (fuel = 3) ---"
  let simple := self_ref
  numbered_trace (run_trace simple 3)
  IO.println ""

-- Assertion: Controlled reaction is deterministic
#eval! do
  if run liar 3 == node (enter (cap liar)) then
    IO.println "✓ Controlled reaction verified: paradox → cap → enter → node"
  else
    IO.println "✗ Unexpected result"

-- Assertion: Nested paradox reaches stable form
#eval! do
  let nested := named "Outer" (named "Inner" self_ref)
  let result := run nested 3
  let expected := node (enter (cap nested))
  if result == expected then
    IO.println "✓ Nested paradox stabilizes in 3 steps"
  else
    IO.println s!"Result: {repr result}"

-- Proof: Works with ANY names (aka structurally it processes the outermost name first)
#eval! do
  let alice := named "Alice" (named "Bob" self_ref)
  IO.println s!"Alice-Bob test: {repr (step alice)}"
