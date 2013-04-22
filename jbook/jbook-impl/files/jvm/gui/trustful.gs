gui_pc :: Nat
gui_pc = pc

gui_meth :: MRef
gui_meth = meth


execMachine :: Rule ()
execMachine = not(halt) =>> do
  case language of
       5 -> trustfulVM__D
       4 -> trustfulVM__N
       3 -> trustfulVM__E
       2 -> trustfulVM__O
       1 -> trustfulVM__C
       0 -> trustfulVM__I


