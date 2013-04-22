gui_pc :: Nat
gui_pc = pc

gui_meth :: MRef
gui_meth = meth


execMachine :: Rule ()
execMachine = not(halt) =>> do
   case language of
     5 -> defensiveVM__D
     4 -> defensiveVM__N
     3 -> defensiveVM__E
     2 -> defensiveVM__O
     1 -> defensiveVM__C
     0 -> defensiveVM__I

