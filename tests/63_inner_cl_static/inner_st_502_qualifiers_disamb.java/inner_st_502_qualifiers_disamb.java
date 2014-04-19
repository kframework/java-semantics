/*
Inner class qualifiers disambiguation.
  Classes p1.A, p1.B, p2.B, p1.A.C, p1.B.C, p2.B.C

  From the context p1.A, instantiate the expressions:
    - new C()
    - new B.C()
    - new p2.B.C()
*/

public class inner_st_502_qualifiers_disamb {

  public static void main(String[] args) {
    p1.A.test();
    System.out.println("Done!");
  }
}

