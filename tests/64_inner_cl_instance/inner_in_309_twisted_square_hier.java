/*
Twisted square hierarchy. S, S.A < O.B, O < S, O.B.
  Instantiate S.A with both the same outer instance as O.B or a different instance.
  For this, use two constructors for A - one with argument O, for the base class,
    and other with no argument. Argument for the base class will be S.this.
  Inside B, discriminate between outer S and base S by using no qualifier or indirection methods from A.
*/

public class inner_in_309_twisted_square_hier {
  public static void main(String[] args) {
    O o = new O(1);
    System.out.println("o.new A(o).test():");
    o.new A().test();
    System.out.println();
    System.out.println("o.new A(new O(2)).test():");
    new S(2).new A(o).test();
    System.out.println("Done!");
  }
}

class S {

  int sv;
  String sf() {return "S[sv=" + sv + "].sf()";}

  S(int id) {
    sv = id;
  }

  class A extends O.B {

    A() {
      ((O) S.this).super();
    }

    A(O o) {
      o.super();
    }

    void test() {
      System.out.println("S.A: sv          = " + sv);
      System.out.println("S.A: sf()        = " + sf());
      System.out.println("S.A: S.this.sv   = " + S.this.sv);
      System.out.println("S.A: S.this.sf() = " + S.this.sf());
      System.out.println("S.A: af()        = " + bf());
    }
  }
}

class O extends S {

  O (int id) {
    super(id);
  }

  B newB() {
    return new B();
  }

  class B {
    String bf() {return "O.B.bf(). sf(): " + sf();}
  }
}
