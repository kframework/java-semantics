/*
Static field, accessed though class qualified expression for read/write.

Example LTL verifications.

  kjkompile.sh --threading

Eventually static field A.v will be 7:

  kjrun.sh --ltlmc="<>Ltl(A.v == 7)" ../tests/52_static_fields/static_f_101_qualified.java

At any moment static field A.v is 7 (false):

  kjrun.sh --ltlmc="[]Ltl(A.v == 7)" ../tests/52_static_fields/static_f_101_qualified.java

Once static field A.v reaches value 7, it stays 7:

  kjrun.sh --ltlmc="[]Ltl ((A.v == 7) ->Ltl []Ltl (A.v == 7) )" \
    ../tests/52_static_fields/static_f_101_qualified.java
*/

public class static_f_101_qualified {
  public static void main(String[] args) {
    A.v = 7;
    System.out.println(A.v);
    System.out.println("Done!");
  }
}

class A {
  static int v;
}
