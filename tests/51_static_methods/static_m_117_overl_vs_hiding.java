/*
Overwriting vs hiding.
  A: f(), static g().
  B < A: f(), static g(). Call both from (A)a, (B)b, (B)a.
*/

public class static_m_117_overl_vs_hiding {
  public static void main(String[] args) {
    A aa = new A();
    aa.f();
    aa.s_g();
    B bb = new B();
    bb.f();
    bb.s_g();
    A ab = bb;
    ab.f();
    ab.s_g();
    System.out.println("Done!");
  }
}

class A {
  void f() {
    System.out.println("A.f()");
  }

  static void s_g() {
    System.out.println("A.s_g()");
  }
}

class B extends A {
  void f() {
    System.out.println("B.f()");
  }

  static void s_g() {
    System.out.println("B.s_g()");
  }
}

