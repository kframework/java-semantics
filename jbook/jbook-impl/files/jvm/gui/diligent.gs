gui_pc :: Nat
gui_pc = if isChecked then
            pc
          else
--            case reorder(dom(changed),code(vmeth)) of
            case expr2list(dom(changed)) of
               pc : _ -> pc
               _      -> -1

gui_meth :: MRef
gui_meth = if isChecked then
              meth
            else
              if emptyDom(changed) && length(verifyMeths)>1
               then top(init(verifyMeths))
               else vmeth


execMachine :: Rule ()
execMachine = not(halt) =>> do
  case language of
    5 -> diligentVM__D
    4 -> diligentVM__N
    3 -> diligentVM__E
    2 -> diligentVM__O
    1 -> diligentVM__C
    0 -> diligentVM__I



