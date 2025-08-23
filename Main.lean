-- Main entry point for the Gödel Mirror system
import GodelMirror.Examples

def main : IO Unit := do
  IO.println "=== Gödel Mirror: Paradox Resolution Demonstration ==="
  IO.println ""
  
  IO.println "1. Paradoxical term (Liar paradox):"
  numbered_trace (run_trace paradoxical_term 4)
  IO.println ""
  
  IO.println "2. Gödel's example:"  
  numbered_trace (run_trace godel_example 4)
  IO.println ""
  
  IO.println "3. Simple self-reference:"
  numbered_trace (run_trace simple_paradox 4)
  IO.println ""
  
  IO.println "=== System demonstrates: paradox → cap → enter → node ==="