-- Defines the core syntax of the Gödel Mirror calculus.

-- The set of symbolic expressions, or terms.
inductive MirrorSystem : Type where
  | base     : MirrorSystem
  | node     : MirrorSystem → MirrorSystem
  | self_ref : MirrorSystem
  | cap      : MirrorSystem → MirrorSystem  -- Encapsulate
  | enter    : MirrorSystem → MirrorSystem  -- Reenter
  | named    : String → MirrorSystem → MirrorSystem
  deriving Repr, BEq, DecidableEq

-- The set of states used to classify terms for reduction.
inductive MirrorState : Type where
  | Normal   -- A standard, reducible term
  | Paradox  -- A term representing a self-referential contradiction
  | Integrate-- A term that has encapsulated a paradox
  | Reentry  -- A term being reintroduced into the system
