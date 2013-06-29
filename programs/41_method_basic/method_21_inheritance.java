/*
Method inheritance.
  - Three classes. A < B < C. A{f()} B{g()} C{h()} C c; c.f(); c.g(); c.h();
*/

public class method_21_inheritance {

  public static void main(String[] args) {
    C c = new C();
    c.f();
    c.g();
    c.h();
    System.out.println("Done!");
  }
}

class A{
  void f() {
    System.out.println("A.f()");
  }
}

class B extends A{
  void g() {
    System.out.println("B.g()");
  }
}

class C extends B{
  void h() {
    System.out.println("C.h()");
  }
}

