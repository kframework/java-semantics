/*
Qualified super as qualifier himself.
  Classes O3 < O2 < O1, O3.C < A. Of them, classes O3, O1, C, A all have v, f().
  Call from C: v(write), v(read), f() using qualifiers:
  - <no qualifier>
  - this
  - super
  - O3.this
  - O3.super
*/

public class inner_in_43_qualified_super {
  public static void main(String[] args) {
    new O3().new C().test();
    System.out.println("Done!");
  }
}

class O1 {
  int v = 10;
  String f() {return "O1.f()";}
}

class O2 extends O1 {}

class A {
  int v = 90;
  String f() {return "A.f()";}
}

class O3 extends O2 {

  int v = 30;
  String f() {return "O3.f()";}

  class C extends A {

    int v = 300;
    String f() {return "C.f()";}

    void test() {
      System.out.println("O3.C: v           = " + v);
      System.out.println("O3.C: v=1         = " + (v=1));
      System.out.println("O3.C: v           = " + v);
      System.out.println("O3.C: f()         = " + f());
      System.out.println("O3.C: this.v      = " + this.v);
      System.out.println("O3.C: this.v=2    = " + (this.v=2));
      System.out.println("O3.C: this.v      = " + this.v);
      System.out.println("O3.C: this.f()    = " + this.f());
      System.out.println("O3.C: super.v     = " + super.v);
      System.out.println("O3.C: super.v=3   = " + (super.v=3));
      System.out.println("O3.C: super.v     = " + super.v);
      System.out.println("O3.C: super.f()   = " + super.f());
      System.out.println("O3.C: O3.this.v   = " + O3.this.v);
      System.out.println("O3.C: O3.this.v=4 = " + (O3.this.v=4));
      System.out.println("O3.C: O3.this.v   = " + O3.this.v);
      System.out.println("O3.C: O3.this.f() = " + O3.this.f());
      System.out.println("O3.C: O3.super.v  = " + O3.super.v);
      System.out.println("O3.C: O3.super.v=5= " + (O3.super.v=5));
      System.out.println("O3.C: O3.super.v  = " + O3.super.v);
      System.out.println("O3.C: O3.super.f()= " + O3.super.f());
    }
  }
}
