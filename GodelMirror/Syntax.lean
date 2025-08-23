-- Defines the core syntax of the Gödel Mirror calculus.

-- The set of symbolic expressions, or terms.
inductive MirrorSystem : Type where
  | base     : MirrorSystem
  | node     : MirrorSystem → MirrorSystem
  | self_ref : MirrorSystem
  | cap      : MirrorSystem → MirrorSystem  -- Encapsulate (formerly embody)
  | enter    : MirrorSystem → MirrorSystem  -- Reenter (formerly reenter)
  | named    : String → MirrorSystem → MirrorSystem

-- The set of states used to classify terms for reduction.
inductive MirrorState : Type where
  | Normal   -- A standard, reducible term
  | Paradox  -- A term representing a self-referential contradiction
  | Integrate-- A term that has encapsulated a paradox (formerly Emergence)
  | Reentry  -- A term being reintroduced into the system