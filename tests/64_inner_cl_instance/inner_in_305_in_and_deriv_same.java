/*
Superposition of nesting and inheritance. Classes O, O.A < O. In any case the enclosing
  instance of A and the base instance will be different instances.
  Instantiate a from O and from a static context.
  Inside A, discriminate between outer O and base O by using O.this, simple this and super as qualifier,
  also unqualified calls.
*/

public class inner_in_305_in_and_deriv_same {
  public static void main(String[] args) {
    new O(1).new A().test();
    System.out.println("Done!");
  }
}

class O {

  int ov;
  String of() {return "of()";}

  O(int id) {
    ov = id;
  }

  class A extends O {
    int av = 10;
    String af() {return "af()";}

    A() {
      super(2);
    }

    void test() {
      System.out.println("O.A: av          = " + av);
      System.out.println("O.A: af()        = " + af());
      System.out.println("O.A: ov          = " + ov);
      System.out.println("O.A: of()        = " + of());
      System.out.println("O.A: this.ov     = " + this.ov);
      System.out.println("O.A: this.of()   = " + this.of());
      System.out.println("O.A: super.ov    = " + super.ov);
      System.out.println("O.A: super.of()  = " + super.of());
      System.out.println("O.A: O.this.ov   = " + O.this.ov);
      System.out.println("O.A: O.this.of() = " + O.this.of());
    }
  }
}
