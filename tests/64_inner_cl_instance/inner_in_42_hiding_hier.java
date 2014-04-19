/*
Classes O, S, O.A < S. All three have the field v, method f().
  From A call: v, f(), this.v, this.f(), super.v, super.f(), O.this.v, O.this.f(), A.this.v, A.this.f().
*/

public class inner_in_42_hiding_hier {
  public static void main(String[] args) {
    new O().new A().test();
    System.out.println("Done!");
  }
}

class S {
  int v = 1;
  String f() {return "S.f()";}
}

class O {

  int v = 2;
  String f() {return "O.f()";}

  class A extends S {

    int v = 30;
    String f() {return "A.f()";}

    void test() {
      System.out.println("O.A: v          = " + v);
      System.out.println("O.A: f()        = " + f());
      System.out.println("O.A: this.v     = " + this.v);
      System.out.println("O.A: this.f()   = " + this.f());
      System.out.println("O.A: A.this.v   = " + A.this.v);
      System.out.println("O.A: A.this.f() = " + A.this.f());
      System.out.println("O.A: super.v    = " + super.v);
      System.out.println("O.A: super.f()  = " + super.f());
      System.out.println("O.A: O.this.v   = " + O.this.v);
      System.out.println("O.A: O.this.f() = " + O.this.f());
    }
  }
}
