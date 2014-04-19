/*
15. Inheritance, methods with other names, fields.
    A: f(int), int i, g(). B: f() int j, h(), B < A.
    - Calls: B.f(int), B.f(), g(), h().
*/

public class overload_15_inherit_and_others {

  public static void main(String[] args) {
    B b = new B();
    b.f(0);
    b.f();
    b.g();
    b.h();

    System.out.println("Done!");
  }
}

class A {
  int i;

  void f(int a) {
    System.out.println("A.f(int)");
  }

  void g() {
    System.out.println("A.g()");
  }
}

class B extends A {
  int j;

  void f() {
    System.out.println("B.f()");
  }

  void h() {
    System.out.println("B.h()");
  }
}

