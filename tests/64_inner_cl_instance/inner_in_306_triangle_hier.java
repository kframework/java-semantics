/*
Triangle hierarchy: S, O < S, O.A < S. In any case the enclosing instance of A and the base instance
  will be different instances. Instantiate A from O, from static context via a qualifier of type O.
  Inside A, discriminate between outer S and base S by using S.this, this, super qualifier, also unqualified calls.
*/

public class inner_in_306_triangle_hier {
  public static void main(String[] args) {
    new O().new A().test();
    System.out.println("Done!");
  }
}

class S {

  int sv;
  String sf() {return "sf()";}

  S(int id) {
    sv = id;
  }
}

class O extends S {

  O() {
    super(1);
  }

  class A extends S {

    A() {
      super(2);
    }

    void test() {
      System.out.println("O.A: sv          = " + sv);
      System.out.println("O.A: sf()        = " + sf());
      System.out.println("O.A: this.sv     = " + this.sv);
      System.out.println("O.A: this.sf()   = " + this.sf());
      System.out.println("O.A: super.sv    = " + super.sv);
      System.out.println("O.A: super.sf()  = " + super.sf());
      System.out.println("O.A: O.this.sv   = " + O.this.sv);
      System.out.println("O.A: O.this.sf() = " + O.this.sf());
    }
  }
}
