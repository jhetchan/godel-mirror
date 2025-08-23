# Contributing to Gödel Mirror

Thank you for your interest in contributing to the Gödel Mirror project. This document outlines the guidelines for contributions.

## Areas for Contribution

We welcome contributions in several areas, particularly those related to the "Open Problems" section of the accompanying paper:

* **Extending the Calculus**: Proposing and formalizing extensions with richer type systems (e.g., dependent types).
* **Alternative Semantics**: Developing a full denotational or categorical semantics for the system.
* **New Meta-Theory**: Proving new properties of the system, such as confluence for a specific fragment.
* **Improving the Formalization**: Refactoring the existing proofs for clarity or efficiency.

## How to Contribute

1.  **Open an Issue**: Before starting significant work, please open a GitHub issue to discuss your proposed changes. This ensures that your contribution aligns with the project's goals.
2.  **Fork and Branch**: Fork the repository and create a new branch for your feature or bugfix.
3.  **Develop and Prove**: Make your changes and ensure that all existing proofs still compile (`lake build`). Any new theorems should be accompanied by their formal proofs in Lean.
4.  **Submit a Pull Request**: Open a pull request against the `main` branch. Please provide a clear description of the changes and link to the relevant issue.

All contributions are expected to maintain a high standard of formal rigor.