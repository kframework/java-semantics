/*
Case B < A < I1. Class A doesn't implement all the methods of the interface. One method is
  not mentioned in A, the other one is redeclared abstract, the third one is implemented.
  They are all re-implemented by subclass B. Call the method through Intf, A, B.
*/

public class interface_23_abstract_propagation {
  public static void main(String[] args) {
    B b = new B();
    b.f();
    b.g(0);
    b.h(true);

    A a = (A)b;
    a.f();
    a.g(0);
    a.h(true);

    I1 i1 = (I1)a;
    i1.f();
    i1.g(0);
    i1.h(true);

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
  void g(int a);
  void h(boolean b);
}

abstract class A implements I1 {
  public void f() {
    System.out.println("A.f()");
  }

  public abstract void g(int a);
}

class B extends A {
  public void f() {
    System.out.println("B.f()");
  }

  public void g(int a) {
    System.out.println("B.g(int)");
  }

  public void h(boolean b) {
    System.out.println("B.h(bool)");
  }
}

