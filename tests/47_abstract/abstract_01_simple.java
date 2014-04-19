/*
Simple test.
  - A: abstract f()
  - B < A: concrete f()
  - main:
    - call (A)B.f()
  Should work for ignoring semantics of abstract methods.
*/

abstract class A {
  abstract void f();
}

class B extends A {
  void f() {
    System.out.println("B.f()");
  }
}

public class abstract_01_simple {
  public static void main(String[] args) {
    A b = new B();
    b.f();
    System.out.println("Done!");
  }
}
