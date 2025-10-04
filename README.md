# Gödel Mirror – ITP 2025 Demo
This branch contains the version of the code used in my [ITP 2025 Lean Workshop](https://leanprover-community.github.io/itp-2025-lean-workshop/) presentation:

> **Gödel Mirror: A Formal System for Contradiction-Driven Recursion**
> *Jhet Chan*
> https://arxiv.org/abs/2509.16239

The Gödel Mirror is a minimal, paraconsistent formal system that treats self-referential paradox not as an error, but as a deterministic control signal for structural transformation. This work provides a verifiable calculus where contradiction is metabolized into new syntactic structure without leading to logical explosion.

---

## Repository Structure

The formalization is organized into clean, modular components:

| File Path                      | Description                                            |
|--------------------------------|--------------------------------------------------------|
| `GodelMirror/Syntax.lean`      | Core inductive types and data structures              |
| `GodelMirror/Semantics.lean`   | Operational semantics and fuel-based evaluator        |
| `GodelMirror/MetaTheory.lean`  | Formal proofs of system properties                    |
| `GodelMirror/Demo.lean`        | **Main workshop demo** with emoji traces              |
| `GodelMirror/Examples.lean`    | Extended examples and completion demonstrations       |
| `lakefile.toml`                | Lake build configuration                              |

---

## Building and Running

This project is built using the [Lean 4 proof assistant](https://lean-lang.org/) and its build manager, [Lake](https://github.com/leanprover/lake).

### Prerequisites
You must have a working Lean 4 environment. We recommend installing it via `elan`. See the official [Lean installation instructions](https://lean-lang.org/lean4/doc/setup.html).

### Steps
1.  **Clone the repository:**
    ```sh
    git clone https://github.com/jhetchan/godel-mirror.git
    cd godel-mirror
    ```
2.  **Build the project:**
    Fetch the dependencies and compile the Lean files.
    ```sh
    lake build
    ```
3.  **Run the workshop demo:**
    To see the interactive demonstration with emoji traces:
    ```sh
    lake build GodelMirror.Demo
    ```
    This runs the main workshop demo from `GodelMirror/Demo.lean`.

    Or build everything (includes extended examples):
    ```sh
    lake build
    ```

---

## Key Features

### Fuel-Based Evaluator
The system uses a **fuel-based approach** for executable demonstrations, avoiding the complexity of proving termination for partial recursive functions. This makes the code clean, workshop-ready, and easy to demonstrate live.

```lean
-- The Liar paradox: "This statement is false"
def liar : MirrorSystem := named "Liar" self_ref

-- Watch it stabilize over 3 steps
#eval! run liar 3
-- Output: 🏷 'Liar' → 🔥 cap → 🌱 enter → 🔁 node
```

### Interactive Traces
Emoji-based output makes the transformation cycle visually clear:
- 🏷 Named paradoxes
- 🪞 Self-reference
- 🔥 Encapsulation (cap)
- 🌱 Reentry (enter)
- 🔁 Stable nodes
- 📦 Base terms (non-paradoxical)

### Paradox Detection
The system selectively detects paradoxes - it doesn't hallucinate them where they don't exist:

**Paradoxical term** (`self_ref`):
```
Step 0: 🪞 self_ref
Step 1: 🔥 cap(🪞 self_ref)      ← Detected! Encapsulate
Step 2: 🌱 enter(🔥 cap(...))     ← Reentry
Step 3: 🔁 node(🌱 enter(...))    ← Stabilize
```

**Non-paradoxical term** (`base`):
```
Step 0: 📦 base
Step 1: 🔁 node(📦 base)          ← No cap/enter - straight to node
Step 2: 🔁 node(🔁 node(...))     ← Just wraps normally
Step 3: 🔁 node(🔁 node(...))     ← Continues wrapping
```

Only terms containing `self_ref` trigger the paradox resolution cycle. Normal terms are left alone.

---

## Formalization Status

### Fully Proven Theorems
- **Controlled Reaction to Paradox** - Deterministic 3-step cycle
- **Progress** - All non-value terms can step forward
- **Label Preservation** - Names preserved through reduction
- **Deterministic Step Function** - Each state has exactly one successor

### Current Approach
This workshop version focuses on **executable demonstrations** using fuel-based evaluation. The system uses:
- `run : MirrorSystem → Nat → MirrorSystem` - Fuel-limited evaluation
- `step : MirrorSystem → MirrorSystem` - Single-step semantics
- `completeFuel : Nat → MirrorSystem → MirrorSystem` - Demo-only completion

**Note:** Formal verification of weak normalization and completion properties is planned for the LMCS journal version using an inductive relation formulation. See the codebase comments for the relational approach outline.

**Statistics:**
- **439 lines** of Lean code
- **5 modules** (Syntax, Semantics, MetaTheory, Demo, Examples)
- **7 proven theorems** with complete proofs
- **0 sorry axioms** - all demonstrations are executable

---

## Workshop Demo

The repository includes a complete workshop demonstration in `GodelMirror/Demo.lean`:

```lean
-- Demo 1: The classic Liar paradox
def liar : MirrorSystem := named "Liar" self_ref

-- Demo 2: Nested paradoxes
def nested := named "Outer" (named "Inner" self_ref)

-- Demo 3: Raw self-reference
def simple := self_ref

-- Demo 4: Non-paradoxical terms (proves selective detection)
def normal := base
def labeled := named "Foo" base
```

Each demo shows the transformation cycle with step-by-step emoji traces, plus automated assertions verifying the controlled reaction. Demo 4 proves the system doesn't hallucinate paradoxes - only `self_ref` triggers the cap→enter→node cycle.

---

## Documentation

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development guidelines
- **Code comments** - Inline documentation throughout

---

## License

This work is licensed under the MIT License. See the `LICENSE` file for details.

---

## Citation

To cite this work:

```bibtex
@misc{chan2025godelmirrorformalcontradictiondriven,
      title={G\"odel Mirror: A Formal System For Contradiction-Driven Recursion},
      author={{Jhet Chan}},
      year={2025},
      eprint={2509.16239},
      archivePrefix={arXiv},
      primaryClass={cs.LO},
      url={https://arxiv.org/abs/2509.16239},
}
```

---

## Acknowledgments

This formalization demonstrates how modern proof assistants like Lean 4 can make exotic formal systems accessible, executable, and verifiable. Special thanks to the Lean community for their excellent documentation and tooling.
