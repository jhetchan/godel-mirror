# Lean 4 Lessons Learned: Proof Automation and Simplification

This document captures key lessons learned while mechanizing the Gödel Mirror meta-theory in Lean 4, particularly around proof automation, the `simp` tactic, and the `@[simp]` attribute.

## Background: The Problem

Our initial proofs failed with errors like:
```lean
error: unsolved goals
⊢ (match if (match t with | named a self_ref => true | ...) = true then ...)
```

The proofs were written with simple `simp` tactics that worked in theory but failed in practice due to excessive unfolding of recursive definitions.

## Key Concepts

### 1. The `simp` Tactic

The `simp` tactic is Lean's primary automation tool for simplifying goals using:
- Definitional equality (beta reduction, eta conversion)
- Lemmas marked with `@[simp]` attribute
- Built-in simplification rules

**However**, `simp` can be too aggressive:
- It unfolds definitions eagerly
- It can create exponentially large terms
- It may unfold recursively without terminating

### 2. The `@[simp]` Attribute

The `@[simp]` attribute registers a theorem or definition as a **simplification lemma** in Lean's simp set.

```lean
@[simp] theorem is_paradox_self_ref : is_paradox self_ref = true := rfl
```

This tells the `simp` tactic: "whenever you see `is_paradox self_ref`, rewrite it to `true`."

### 3. When NOT to Use `@[simp]` on Definitions

**Anti-pattern (causes problems):**
```lean
@[simp] def step (t : MirrorSystem) : MirrorSystem :=
  match classify t with
  | MirrorState.Paradox => cap t
  | MirrorState.Integrate => enter t
  | MirrorState.Reentry => node t
  | MirrorState.Normal => node t
```

**Problems:**
- `simp` will always unfold `step`, leading to nested matches
- Creates huge unreadable goal states
- May not terminate for recursive functions
- Loses abstraction (defeats the purpose of having named functions)

**Better approach:**
```lean
-- Definition without @[simp]
def step (t : MirrorSystem) : MirrorSystem := ...

-- Targeted simp lemmas for specific cases
@[simp] theorem step_paradox (t : MirrorSystem) (h : is_paradox t = true) :
    step t = cap t := ...
```

## Our Solution: Targeted Simp Lemmas

### Strategy 1: Specific Case Lemmas

Instead of marking recursive functions with `@[simp]`, we created specific lemmas for concrete cases:

```lean
-- NOT @[simp] on the definition
def paradox : MirrorSystem → Bool
| self_ref => true
| node ms => paradox ms
| base => false
| cap _ => false
| enter ms => paradox ms
| named _ ms => paradox ms

-- @[simp] on specific cases only
@[simp] theorem paradox_self_ref : paradox self_ref = true := rfl
@[simp] theorem paradox_base : paradox base = false := rfl
@[simp] theorem paradox_cap (t : MirrorSystem) : paradox (cap t) = false := rfl
```

**Benefits:**
- `simp` knows `paradox self_ref = true` without unfolding the entire definition
- Preserves abstraction for other cases
- Avoids infinite unfolding

### Strategy 2: Computational Lemmas for Common Patterns

```lean
@[simp] theorem integrate_cap (t : MirrorSystem) :
    integrate (cap t) = is_paradox t := rfl

@[simp] theorem valid_reentry_enter_cap (t : MirrorSystem) :
    valid_reentry (enter (cap t)) = true := rfl

@[simp] theorem run_zero (t : MirrorSystem) : run t 0 = t := rfl
@[simp] theorem run_succ (t : MirrorSystem) (n : Nat) :
    run t (Nat.succ n) = run (step t) n := rfl
```

These lemmas:
- Expose the computational behavior without full unfolding
- Guide `simp` through multi-step reductions
- Keep goals readable

### Strategy 3: Controlled Unfolding with `unfold` and `simp only`

When `simp` is too aggressive, use controlled tactics:

```lean
theorem paradox_leads_to_cap (t : MirrorSystem) (h : is_paradox t = true) :
    step t = cap t := by
  unfold step classify              -- Manually unfold specific definitions
  simp only [h, if_true]           -- Simplify ONLY using specific lemmas
```

**`simp only [...]` vs `simp`:**
- `simp`: Uses ALL simp lemmas in the environment
- `simp only [...]`: Uses ONLY the specified lemmas
- Much more predictable and maintainable

### Strategy 4: Boolean Simplification

When working with `Bool`, you often need explicit simplification rules:

```lean
simp only [paradox_cap, Bool.false_eq_true, if_false, h_integrate, if_true]
```

Common boolean lemmas:
- `Bool.false_eq_true` : simplifies `false = true` to contradiction
- `if_true` : simplifies `if true then a else b` to `a`
- `if_false` : simplifies `if false then a else b` to `b`

## Proof Pattern: Step-by-Step Rewriting

Instead of relying on `simp` to do everything, we used explicit rewriting:

```lean
theorem controlled_reaction_to_paradox (t : MirrorSystem) (h : is_paradox t = true) :
    run t 3 = node (enter (cap t)) := by
  have step1 := paradox_leads_to_cap t h    -- Prove each step
  have step2 := cap_leads_to_enter t h
  have step3 := enter_leads_to_node t
  simp only [run_succ, run_zero]            -- Expand run definition
  rw [step1, step2, step3]                  -- Apply step lemmas
```

**Benefits:**
- Each step is explicit and verifiable
- Easy to debug when proofs fail
- Clear correspondence to paper proofs
- Reusable lemmas for other theorems

## Lean 4 Specific Notes

### `lemma` vs `theorem`

In our codebase, we initially used `lemma` but got errors:
```
error: unexpected identifier; expected command
```

**Lesson:** In Lean 4, `lemma` is not a built-in keyword. You must either:
1. Use `theorem` instead (recommended)
2. Import a library that provides `lemma` as an alias

We chose to use `theorem` throughout for consistency with Lean 4 core.

### Pattern Matching in Proofs

When working with inductive types, `simp` may not simplify pattern matches automatically. Use:
- `cases` tactic to split on constructors
- `match` expressions in term mode
- Specific lemmas for each constructor

### Reflexivity is Powerful

Many of our simp lemmas are just `rfl`:
```lean
@[simp] theorem paradox_self_ref : paradox self_ref = true := rfl
```

This works because Lean's definitional equality (`rfl`) is very strong. If two terms are **computationally equal**, they can be proved with `rfl`.

## General Principles

1. **@[simp] is for lemmas, not recursive definitions**
   - Mark theorems stating equations as `@[simp]`
   - Don't mark complex recursive functions as `@[simp]`

2. **Prefer specific over general**
   - Targeted simp lemmas for concrete cases
   - Better than one lemma that applies everywhere

3. **Control your automation**
   - `simp only` when you need predictability
   - `unfold` for explicit unfolding
   - `rw` for explicit rewriting

4. **Boolean reasoning needs explicit lemmas**
   - `if_true`, `if_false`
   - `Bool.false_eq_true`
   - Equality simplifications

5. **Prove intermediate lemmas**
   - Break complex proofs into steps
   - Each step should be independently meaningful
   - Reusable for other proofs

## Comparison: Before and After

### Before (doesn't work):
```lean
@[simp] def step (t : MirrorSystem) : MirrorSystem := ...
@[simp] def run (t : MirrorSystem) (n : Nat) : MirrorSystem := ...

theorem controlled_reaction_to_paradox (t : MirrorSystem) (h : is_paradox t = true) :
    run t 3 = node (enter (cap t)) := by
  simp [run, step, classify, is_paradox, is_integrate, integrate, valid_reentry, h]
  -- Error: unsolved goals (huge unreadable term)
```

### After (works):
```lean
-- No @[simp] on definitions
def step (t : MirrorSystem) : MirrorSystem := ...
def run (t : MirrorSystem) (n : Nat) : MirrorSystem := ...

-- Specific simp lemmas
@[simp] theorem run_succ (t : MirrorSystem) (n : Nat) : run t (Nat.succ n) = run (step t) n := rfl
@[simp] theorem integrate_cap (t : MirrorSystem) : integrate (cap t) = is_paradox t := rfl

-- Structured proof
theorem controlled_reaction_to_paradox (t : MirrorSystem) (h : is_paradox t = true) :
    run t 3 = node (enter (cap t)) := by
  have step1 := paradox_leads_to_cap t h
  have step2 := cap_leads_to_enter t h
  have step3 := enter_leads_to_node t
  simp only [run_succ, run_zero]
  rw [step1, step2, step3]
  -- Proof succeeds!
```

## Takeaways for ITP Workshop

1. **Proof automation is a double-edged sword**
   - Great for simple goals
   - Can make complex proofs impossible

2. **Understanding what `simp` does is crucial**
   - Not magic
   - Works by term rewriting
   - Can be controlled and debugged

3. **The `@[simp]` attribute is for equations, not definitions**
   - Mark lemmas that state useful equalities
   - Don't mark everything

4. **Structure your proofs like your paper proofs**
   - One lemma per logical step
   - Explicit dependencies
   - Readable proof terms

5. **When automation fails, go manual**
   - `unfold`, `rw`, `simp only`
   - Step-by-step rewriting
   - Always an escape hatch

## Further Reading

- [Lean 4 Manual: Simplification](https://lean-lang.org/theorem_proving_in_lean4/tactics.html#simplification)
- [Lean 4 Mathlib: simp normal form](https://leanprover-community.github.io/mathlib4_docs/docs/simp.html)
- [Lean 4 Metaprogramming Book](https://leanprover.github.io/lean4/doc/metaprogramming-book.html)

---

**Author:** Jhet C. - Gödel Mirror formalization, 2025
**Context:** ITP Lean 4 Workshop preparation



Added the Progress theorem to MetaTheory.lean:46-51. What was added:
is_value predicate: Defines what counts as a final value (only base in this system)
progress theorem: Proves that every term either is a value OR can take a step
The proof technique:
Case split on the term structure
base is a value: left; rfl
All other constructors can step: right; refine ⟨step _, rfl⟩
Very concise (2 lines) using all_goals combinator
This is a standard meta-theoretic property showing the system is not stuck - every non-value term has a reduction available.