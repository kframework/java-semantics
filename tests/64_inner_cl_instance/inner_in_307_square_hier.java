/*
Square hierarchy. S, A.S, O < S, O.B < A.S.
  Instantiate B from O, or from static context. In the first case enclosing instance of B and A will be the same,
  in the second - different. (Use two different constructors for B).
  In any case, constructor of B should call a qualified superclass constructor.
  (Try the opposite and confirm the compile-time error).
  Inside B, discriminate between outer S and base S by using no qualifier or indirection methods from A.
*/

public class inner_in_307_square_hier {
  public static void main(String[] args) {
    O o = new O(1);
    System.out.println("o.newBSame().test():");
    o.newBSame().test();
    System.out.println();
    System.out.println("o.newBDiff().test():");
    o.newBDiff().test();
    System.out.println("Done!");
  }
}

class S {

  int sv;
  String sf() {return "S[sv=" + sv + "].sf()";}

  S(int id) {
    sv = id;
  }

  class A {
    String af() {return "A.af(): " + sf();}
  }
}

class O extends S {

  O(int id) {
    super(id);
  }

  B newBSame() {
    return new B();
  }

  B newBDiff() {
    return new B(new S(2));
  }

  class B extends A {

    B(){
      super();  //Same as default constructor.
    }

    B(S s) {
      s.super();
    }

    void test() {
      System.out.println("O.B: sv          = " + sv);
      System.out.println("O.B: sf()        = " + sf());
      System.out.println("O.B: O.this.sv   = " + O.this.sv);
      System.out.println("O.B: O.this.sf() = " + O.this.sf());
      System.out.println("O.B: af()        = " + af());
    }
  }
}
