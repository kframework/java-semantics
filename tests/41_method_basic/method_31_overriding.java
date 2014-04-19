/*
Overriding, polymorphism.
  Three classes. A < B < C.
    - A{f() g() h() m()}
    - B{g() h()}
    - C{h() m()}
  Six references: A aa, ab, ac; B bb, bc; C cc;
  All six references call all four methods.
*/

public class method_31_overriding {

  public static void main(String[] args) {
    A a = new A();
    a.f(); a.g(); a.h(); a.m();

    a = new B();
    a.f(); a.g(); a.h(); a.m();

    a = new C();
    a.f(); a.g(); a.h(); a.m();

    B b = new B();
    b.f(); b.g(); b.h(); b.m();

    b = new C();
    b.f(); b.g(); b.h(); b.m();

    C c = new C();
    c.f(); c.g(); c.h(); c.m();

    System.out.println("Done!");
  }
}

class A{
  void f() {
    System.out.println("A.f()");
  }

  void g() {
    System.out.println("A.g()");
  }

  void h() {
    System.out.println("A.h()");
  }

  void m() {
    System.out.println("A.m()");
  }
}

class B extends A{
  void g() {
    System.out.println("B.g()");
  }

  void h() {
    System.out.println("B.h()");
  }
}

class C extends B{
  void h() {
    System.out.println("C.h()");
  }

  void m() {
    System.out.println("C.m()");
  }
}

