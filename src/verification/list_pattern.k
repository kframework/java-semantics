// Copyright (c) 2014-2015 K Team. All Rights Reserved.

module LIST-PATTERN
  imports MAP
  imports JAVA-EXEC
  imports INT-LIST

  syntax Id ::= "val" | "next" | "java.lang.Object" | ".listNode"
  /* list pattern */
  syntax Bag ::= "list" "(" RawRefVal ")" "(" List ")"    [pattern(1)]
  rule <objectStore> ...
    list(objectRef(P:Int, class .listNode))(ListItem(I:Int) L:List)
  => <object>
                 <objectId>
                     P
                 </objectId>
                 <objectType>
                     class .listNode
                 </objectType>
                 <layer>
                     <layerClass>
                         class .listNode
                     </layerClass>
                     <layerEnv>
        val |-> I :: int
        next |-> ?PNext:RawRefVal :: class .listNode
        </layerEnv>
                        <layerEnclosingObject>
                            noValue
                        </layerEnclosingObject>
                    </layer>
                    <layer>
                        <layerClass>
                            class java.lang.Object
                        </layerClass>
                        <layerEnv>
                            .Map
                        </layerEnv>
                        <layerEnclosingObject>
                            noValue
                        </layerEnclosingObject>
                    </layer>
                </object>
    list(?PNext)(L)
    ...
           </objectStore>
           ensures I >=Int -2147483648 andBool I <=Int 2147483647
    [pattern]
  rule <objectStore> ... list(null)(.List) => .Bag ... </objectStore>
    [pattern]

  /* lseg pattern */
  syntax Bag ::= "lseg" "(" RawRefVal "," RawRefVal ")" "(" List ")"    [pattern(2)]
  rule <objectStore> ...
  lseg(objectRef(P:Int, class .listNode), Q:RawRefVal)(ListItem(I:Int) L:List)
    => <object>
                     <objectId>
                         P
                     </objectId>
                     <objectType>
                         class .listNode
                     </objectType>
                     <layer>
                         <layerClass>
                             class .listNode
                         </layerClass>
                         <layerEnv>
            val |-> I :: int
            next |-> ?PNext:RawRefVal :: class .listNode
            </layerEnv>
                            <layerEnclosingObject>
                                noValue
                            </layerEnclosingObject>
                        </layer>
                        <layer>
                            <layerClass>
                                class java.lang.Object
                            </layerClass>
                            <layerEnv>
                                .Map
                            </layerEnv>
                            <layerEnclosingObject>
                                noValue
                            </layerEnclosingObject>
                        </layer>
                    </object>
        lseg(?PNext, Q)(L)
        ...
               </objectStore>

    requires objectRef(P, class .listNode) =/=K Q
    ensures I >=Int -2147483648 andBool I <=Int 2147483647
    [pattern]
  rule <objectStore> ... lseg(P:RawRefVal, P)(.List) => .Bag ... </objectStore>
    [pattern]

  rule <objectStore>
  (<object>
                       <objectId>
                           P
                       </objectId>
                       <objectType>
                           class .listNode
                       </objectType>
                       <layer>
                           <layerClass>
                               class .listNode
                           </layerClass>
                           <layerEnv>
              val |-> I:Int :: int
              next |-> null :: class .listNode
              </layerEnv>
                              <layerEnclosingObject>
                                  noValue
                              </layerEnclosingObject>
                          </layer>
                          <layer>
                              <layerClass>
                                  class java.lang.Object
                              </layerClass>
                              <layerEnv>
                                  .Map
                              </layerEnv>
                              <layerEnclosingObject>
                                  noValue
                              </layerEnclosingObject>
                          </layer>
                      </object>
       => lseg(objectRef(P:Int, class .listNode), null)(ListItem(I)))
       F:Bag </objectStore>
    [pattern-folding]

  rule <objectStore>
         (<object>
                              <objectId>
                                  P:Int
                              </objectId>
                              <objectType>
                                  class .listNode
                              </objectType>
                              <layer>
                                  <layerClass>
                                      class .listNode
                                  </layerClass>
                                  <layerEnv>
                     val |-> I:Int :: int
                     next |-> objectRef(Q:Int, class .listNode) :: class .listNode
                     </layerEnv>
                                     <layerEnclosingObject>
                                         noValue
                                     </layerEnclosingObject>
                                 </layer>
                                 <layer>
                                     <layerClass>
                                         class java.lang.Object
                                     </layerClass>
                                     <layerEnv>
                                         .Map
                                     </layerEnv>
                                     <layerEnclosingObject>
                                         noValue
                                     </layerEnclosingObject>
                                 </layer>
                             </object>
    => lseg(objectRef(P, class .listNode), objectRef(Q, class .listNode))(ListItem(I)))
       <object>
                                <objectId>
                                    Q
                                </objectId>
                                <objectType>
                                    class .listNode
                                </objectType>
                                <layer>
                                    <layerClass>
                                        class .listNode
                                    </layerClass>
                                    <layerEnv>
                       M:Map
                       </layerEnv>
                                       <layerEnclosingObject>
                                           noValue
                                       </layerEnclosingObject>
                                   </layer>
                                   <layer>
                                       <layerClass>
                                           class java.lang.Object
                                       </layerClass>
                                       <layerEnv>
                                           .Map
                                       </layerEnv>
                                       <layerEnclosingObject>
                                           noValue
                                       </layerEnclosingObject>
                                   </layer>
                               </object>
       F:Bag </objectStore>
    [pattern-folding]

  rule <objectStore>
                (<object>
                                     <objectId>
                                         P
                                     </objectId>
                                     <objectType>
                                         class .listNode
                                     </objectType>
                                     <layer>
                                         <layerClass>
                                             class .listNode
                                         </layerClass>
                                         <layerEnv>
                            val |-> I:Int :: int
                            next |-> Q:RawRefVal :: class .listNode
                            </layerEnv>
                                            <layerEnclosingObject>
                                                noValue
                                            </layerEnclosingObject>
                                        </layer>
                                        <layer>
                                            <layerClass>
                                                class java.lang.Object
                                            </layerClass>
                                            <layerEnv>
                                                .Map
                                            </layerEnv>
                                            <layerEnclosingObject>
                                                noValue
                                            </layerEnclosingObject>
                                        </layer>
                                    </object>
    => lseg(objectRef(P:Int, class .listNode), Q)(ListItem(I)))
       lseg(Q, null)(L:List)
       F:Bag </objectStore>
    [pattern-folding]

  rule <objectStore> (<object>
                                                          <objectId>
                                                              P:Int
                                                          </objectId>
                                                          <objectType>
                                                              class .listNode
                                                          </objectType>
                                                          <layer>
                                                              <layerClass>
                                                                  class .listNode
                                                              </layerClass>
                                                              <layerEnv>
                                                 val |-> I:Int :: int
                                                 next |-> Q:RawRefVal :: class .listNode
                                                 </layerEnv>
                                                                 <layerEnclosingObject>
                                                                     noValue
                                                                 </layerEnclosingObject>
                                                             </layer>
                                                             <layer>
                                                                 <layerClass>
                                                                     class java.lang.Object
                                                                 </layerClass>
                                                                 <layerEnv>
                                                                     .Map
                                                                 </layerEnv>
                                                                 <layerEnclosingObject>
                                                                     noValue
                                                                 </layerEnclosingObject>
                                                             </layer>
                                                         </object>
    => lseg(objectRef(P, class .listNode), Q)(ListItem(I)))
       lseg(Q, objectRef(R:Int, class .listNode))(L:List)
       <object>
                                       <objectId>
                                           R
                                       </objectId>
                                       <objectType>
                                           class .listNode
                                       </objectType>
                                       <layer>
                                           <layerClass>
                                               class .listNode
                                           </layerClass>
                                           <layerEnv>
                              M:Map
                              </layerEnv>
                                              <layerEnclosingObject>
                                                  noValue
                                              </layerEnclosingObject>
                                          </layer>
                                          <layer>
                                              <layerClass>
                                                  class java.lang.Object
                                              </layerClass>
                                              <layerEnv>
                                                  .Map
                                              </layerEnv>
                                              <layerEnclosingObject>
                                                  noValue
                                              </layerEnclosingObject>
                                          </layer>
                                      </object>
       F:Bag </objectStore>
    [pattern-folding]

  rule <objectStore> (lseg(P:RawRefVal, Q:RawRefVal)(L1:List)
       lseg(Q, null)(L2:List)
    => lseg(P, null)(L1 L2))
       F:Bag </objectStore>
    [pattern-folding]

  rule <objectStore> (lseg(P:RawRefVal, R:RawRefVal)(L1:List)
       lseg(R, objectRef(Q:Int, class .listNode))(L2:List)
    => lseg(P, objectRef(Q, class .listNode))(L1 L2))
       <object>
                                <objectId>
                                    Q
                                </objectId>
                                <objectType>
                                    class .listNode
                                </objectType>
                                <layer>
                                    <layerClass>
                                        class .listNode
                                    </layerClass>
                                    <layerEnv>
                       M:Map
                       </layerEnv>
                                       <layerEnclosingObject>
                                           noValue
                                       </layerEnclosingObject>
                                   </layer>
                                   <layer>
                                       <layerClass>
                                           class java.lang.Object
                                       </layerClass>
                                       <layerEnv>
                                           .Map
                                       </layerEnv>
                                       <layerEnclosingObject>
                                           noValue
                                       </layerEnclosingObject>
                                   </layer>
                               </object>
       F:Bag </objectStore>
    [pattern-folding]

  rule  <objectStore> (lseg(P:RawRefVal, R:RawRefVal)(L1:List)
       lseg(R, Q:RawRefVal)(L2:List) => lseg(P, Q)(L1 L2))
       lseg(Q, null)(L3:List)
       F:Bag </objectStore>
    [pattern-folding]
endmodule

