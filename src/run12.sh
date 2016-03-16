#!/bin/bash -x



 rm -rf prep/java-prep-kompiled exec/java-exec-kompiled && kjkompile.sh



 rm -f bst.java.pkast      && kjrun.sh verification/bst.java

 rm -f avl.java.pkast      && kjrun.sh verification/avl.java

 rm -f listNode.java.pkast && kjrun.sh verification/listNode.java



 ( cd verification && rm -rf java-verification-kompiled && kompile java-verification.k )



 krun -cMainClass="ListItem(\"bst\")"      --prove verification/bst-find-spec.k       bst.java.pkast      --smt_prelude ../../k/k-distribution/include/z3/search_tree.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"bst\")"      --prove verification/bst-insert-spec.k     bst.java.pkast      --smt_prelude ../../k/k-distribution/include/z3/search_tree.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"bst\")"      --prove verification/bst-delete-spec.k     bst.java.pkast      --smt_prelude ../../k/k-distribution/include/z3/search_tree.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 



 krun -cMainClass="ListItem(\"avl\")"      --prove verification/avl-find-spec.k       avl.java.pkast      --smt_prelude ../../k/k-distribution/include/z3/search_tree.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"avl\")"      --prove verification/avl-insert-spec.k     avl.java.pkast      --smt_prelude ../../k/k-distribution/include/z3/search_tree.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"avl\")"      --prove verification/avl-delete-spec.k     avl.java.pkast      --smt_prelude ../../k/k-distribution/include/z3/search_tree.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 



 krun -cMainClass="ListItem(\"listNode\")" --prove verification/reverse-spec.k        listNode.java.pkast --smt_prelude ../../k/k-distribution/include/z3/sorted_list.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"listNode\")" --prove verification/append-spec.k         listNode.java.pkast --smt_prelude ../../k/k-distribution/include/z3/sorted_list.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 



 krun -cMainClass="ListItem(\"listNode\")" --prove verification/bubble-sort-spec.k    listNode.java.pkast --smt_prelude ../../k/k-distribution/include/z3/sorted_list.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"listNode\")" --prove verification/insertion-sort-spec.k listNode.java.pkast --smt_prelude ../../k/k-distribution/include/z3/sorted_list.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"listNode\")" --prove verification/quicksort-spec.k      listNode.java.pkast --smt_prelude ../../k/k-distribution/include/z3/sorted_list.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

 krun -cMainClass="ListItem(\"listNode\")" --prove verification/merge-sort-spec.k     listNode.java.pkast --smt_prelude ../../k/k-distribution/include/z3/sorted_list.smt2 -v --debug -d verification --symbolic-execution --statistics on --parser "cat" -cDissolveAllExceptOut="false" 

