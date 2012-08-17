/*
36. Multi applicable, + other methods and fields, + inheritance/poly:
    This test assures that all rules for lookupMethod searches the same stack layer -
    either from the top or from the bottom of the stack.
    If some rules search the top and others search the bottom, computation will get stuck.

    - decl:
      - A: f(int), f(long), g(), int x;
      - B: f(int), f(long), g(), int y;
    - call target: B.f(int)
*/

public class overload_36_multi_appl_other {

  public static void main(String[] args) {
    B b = new B();
    b.f(0);

    System.out.println("Done!");
  }
}

class A {

  void f(int a) {
    System.out.println("A.f(int)");
  }

  void f(long a) {
    System.out.println("A.f(long)");
  }

  void g() {
    System.out.println("A.g()");
  }

  int x;
}

class B extends A {

  void f(int a) {
    System.out.println("B.f(int)");
  }

  void f(long a) {
    System.out.println("B.f(long)");
  }

  void g() {
    System.out.println("B.g()");
  }

  int y;
}
