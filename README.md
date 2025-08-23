# Gödel Mirror

This repository contains the complete Lean 4 mechanization for the paper:

> **Gödel Mirror: A Formal System for Contradiction-Driven Recursion** > *Jhet Chan* > (Forthcoming, link to be added upon publication)

The Gödel Mirror is a minimal, paraconsistent formal system that treats self-referential paradox not as an error, but as a deterministic control signal for structural transformation. This work provides a verifiable calculus where contradiction is metabolized into new syntactic structure without leading to logical explosion.

---

## 📂 Repository Structure

The formalization is organized into several modules to ensure clarity and separation of concerns.

| File Path                  | Description                                            |
|----------------------------|--------------------------------------------------------|
| `GodelMirror/Syntax.lean`  | Defines the core inductive types for the calculus.     |
| `GodelMirror/Semantics.lean`| Defines the operational semantics (rewrite rules).     |
| `GodelMirror/MetaTheory.lean`| Contains the formal proofs of the system's properties. |
| `Examples.lean`            | Provides a runnable case study of the paradox cycle.   |
| `lakefile.lean`            | The Lake build configuration file.                     |

---

## 🛠️ Building and Running

This project is built using the [Lean 4 proof assistant](https://lean-lang.org/) and its build manager, [Lake](https://github.com/leanprover/lake).

### Prerequisites
You must have a working Lean 4 environment. We recommend installing it via `elan`. See the official [Lean installation instructions](https://lean-lang.org/toolchain/).

### Steps
1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/jhetchan/godel-mirror.git](https://github.com/jhetchan/godel-mirror.git)
    cd godel-mirror
    ```
2.  **Build the project:**
    Fetch the dependencies and compile the Lean files.
    ```sh
    lake build
    ```
3.  **Run the example:**
    To see the case study trace from the paper, run the `Examples.lean` file.
    ```sh
    lake env lean --run GodelMirror/Examples.lean
    ```

---

## 📜 License

This work is licensed under the MIT License. See the `LICENSE` file for details.