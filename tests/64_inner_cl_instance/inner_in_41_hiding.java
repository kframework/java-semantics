/*
Field and method hiding. O, O.A, O.A.B. O.v, O.f(), A.v, A.f(), B.v, B.f()
  From B, call v, f() by simple name, by using this, by using B.this, A.this, O.this.
*/

public class inner_in_41_hiding {
  public static void main(String[] args) {
    new O().new A().new B().test();
    System.out.println("Done!");
  }
}

class O {

  int v = 1;
  String f() {return "O.f()";}

  class A {

    int v = 20;
    String f() {return "A.f()";}

    class B {

      int v = 300;
      String f() {return "B.f()";}

      void test() {
        System.out.println("O.A.B: v          = " + v);
        System.out.println("O.A.B: f()        = " + f());
        System.out.println("O.A.B: this.v     = " + this.v);
        System.out.println("O.A.B: this.f()   = " + this.f());
        System.out.println("O.A.B: B.this.v   = " + B.this.v);
        System.out.println("O.A.B: B.this.f() = " + B.this.f());
        System.out.println("O.A.B: A.this.v   = " + A.this.v);
        System.out.println("O.A.B: A.this.f() = " + A.this.f());
        System.out.println("O.A.B: O.this.v   = " + O.this.v);
        System.out.println("O.A.B: O.this.f() = " + O.this.f());
      }
    }
  }
}
