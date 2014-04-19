/*
Classes O, O.A, O.B < O.A. Instantiate B from O simple.
  Also instantiate B from a static context, using a qualifier object of type O.
*/

public class inner_in_303_in_deriv_from_in {
  public static void main(String[] args) {
    System.out.println("new O(1).newB().test():");
    new O(1).newB().test();
    System.out.println();
    System.out.println("new O(2).new B().test():");
    new O(2).new B().test();
    System.out.println("Done!");
  }
}

class O {

  int ov;
  String of() {return "of()";}

  O(int id) {
    ov = id;
  }

  B newB() {
    return new B();
  }

  class A {
    int av = 10;
    String af() {return "af()";}
  }

  class B extends A {
    int bv = 20;
    String bf() {return "bf()";}

    void test() {
      System.out.println("O.B: ov   = " + ov);
      System.out.println("O.B: of() = " + of());
      System.out.println("O.B: av   = " + av);
      System.out.println("O.B: af() = " + af());
      System.out.println("O.B: bv   = " + bv);
      System.out.println("O.B: bf() = " + bf());
    }
  }
}
