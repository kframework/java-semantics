// Copyright (c) 2014-2015 K Team. All Rights Reserved.

module TREE-PATTERN
  imports MAP
  imports JAVA-EXEC
  imports INT-SET

  syntax Tree ::= "node" "(" Int "," Tree "," Tree ")"
                | "leaf"

  syntax IntSet ::= "tree_keys" "(" Tree ")"    [function, smtlib(smt_tree_keys)]
  rule tree_keys(node(I:Int, TL:Tree, TR:Tree))
    => { I } U (tree_keys(TL) U tree_keys(TR))
  rule tree_keys(leaf) => .IntSet
  syntax Int ::= "tree_height" "(" Tree ")"     [function, smtlib(smt_tree_height)]

  rule tree_height(node(I:Int, TL:Tree, TR:Tree))
    => 1 +Int maxInt(tree_height(TL), tree_height(TR))
  rule tree_height(leaf) => 0

  syntax Bag ::= "tree" "(" RawRefVal ")" "(" Tree ")"    [pattern(1)]
  rule <objectStore> ...
  tree(objectRef(P:Int, C:ClassType))(node(I:Int, TL:Tree, TR:Tree))
    =>  <object>
            <objectId>
                P
            </objectId>
            <objectType>
                C
            </objectType>
            <layer>
                <layerClass>
                    C
                </layerClass>
                <layerEnv>
                    String2Id("value") |-> I :: int
                    String2Id("left") |-> ?PL:RawRefVal :: C
                    String2Id("right") |-> ?PR:RawRefVal :: C
                </layerEnv>
                <layerEnclosingObject>
                    noValue
                </layerEnclosingObject>
            </layer>
            <layer>
                <layerClass>
                    class String2Id("java.lang.Object")
                </layerClass>
                <layerEnv>
                    .Map
                </layerEnv>
                <layerEnclosingObject>
                    noValue
                </layerEnclosingObject>
            </layer>
        </object>
       tree(?PL)(TL)
       tree(?PR)(TR)
       ...
       </objectStore>
       ensures I >=Int -2147483648 andBool I <=Int 2147483647
    [pattern]

  rule <objectStore> ... tree(null)(leaf) => .Bag ... </objectStore>  [pattern]

  syntax Bool ::= bst(Tree)   [function, smtlib(smt_bst)]
  rule bst(node(I:Int, TL:Tree, TR:Tree))
    => tree_keys(TL) <IntSet { I } andBool { I } <IntSet tree_keys(TR)
       andBool bst(TL) andBool bst(TR)
  rule bst(leaf) => true

  syntax Bag ::= "htree" "(" RawRefVal ")" "(" Tree ")"   [pattern(1)]
  rule <objectStore> ...
  htree(objectRef(P:Int, C:ClassType))(node(I:Int, TL:Tree, TR:Tree))
    =>         <object>
                   <objectId>
                       P
                   </objectId>
                   <objectType>
                       C
                   </objectType>
                   <layer>
                       <layerClass>
                           C
                       </layerClass>
                       <layerEnv>
                           String2Id("value") |-> I :: int
                           String2Id("height") |-> tree_height(node(I, TL, TR)) :: int
                           String2Id("left") |-> ?PL:RawRefVal :: C
                           String2Id("right") |-> ?PR:RawRefVal :: C
                       </layerEnv>
                       <layerEnclosingObject>
                           noValue
                       </layerEnclosingObject>
                   </layer>
                   <layer>
                       <layerClass>
                           class String2Id("java.lang.Object")
                       </layerClass>
                       <layerEnv>
                           .Map
                       </layerEnv>
                       <layerEnclosingObject>
                           noValue
                       </layerEnclosingObject>
                   </layer>
               </object>
       htree(?PL)(TL)
       htree(?PR)(TR)
       ...
        </objectStore>
        ensures I >=Int -2147483648 andBool I <=Int 2147483647 andBool

        tree_height(node(I, TL, TR)) >=Int -2147483648 andBool tree_height(node(I, TL, TR)) <=Int 2147483647
    [pattern]
  rule <objectStore> ... htree(null)(leaf) => .Bag ... </objectStore>   [pattern]

  syntax Bool ::= avl(Tree)   [function, smtlib(smt_avl)]
  rule avl(node(I:Int, TL:Tree, TR:Tree))
    => tree_keys(TL) <IntSet { I } andBool { I } <IntSet tree_keys(TR)
       andBool absInt(tree_height(TL) -Int tree_height(TR)) <=Int 1
       andBool avl(TL) andBool avl(TR)
  rule avl(leaf) => true

  rule tree_height(T:Tree) >=Int 0 => true    [smt-lemma]

endmodule
