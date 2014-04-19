/*
Base and derived, both inner to unrelated top-level classes.
  O1, O2, O2.B < O1.A. Instantiate O2.B, with constructor arg of type O1. Print a field from O2, A,B.
*/

public class inner_in_308_multi_outer_in_hier {
  public static void main(String[] args) {
    new O2().new B(new O1()).test();
    System.out.println("Done!");
  }
}

class O1 {

  String o1v = "O1.o1v";

  class A {
    String av = "O1.A.av";

    String getO1v() {
      return o1v;
    }
  }
}

class O2 {

  String o2v = "O2.o2v";

  class B extends O1.A {

    B(O1 o1){
      o1.super();
    }

    String bv = "O2.B.bv";

    void test() {
      System.out.println("O2.B: bv          = " + bv);
      System.out.println("O2.B: av          = " + av);
      System.out.println("O2.B: o2v         = " + o2v);
      System.out.println("O2.B: getO1v()    = " + getO1v());
    }
  }
}
