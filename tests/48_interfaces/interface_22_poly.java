/*
Interface polymorphism.
  Interface I1:
    - void f()
    - void g()
  - class A < I1:
    - implements f, g
  - class B < I1:
    - implements f, g
  - main:
    - call (I1)A.f(), (I1)A.g(), (I1)B.f(), (I1)B.g(), use just one var.
*/

public class interface_22_poly {
  public static void main(String[] args) {
    I1 i1 = new A();
    i1.f();
    i1.g();

    i1 = new B();
    i1.f();
    i1.g();

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
  void g();
}

class A implements I1 {
  public void f() {
    System.out.println("A.f()");
  }

  public void g() {
    System.out.println("A.g()");
  }
}

class B implements I1 {
  public void f() {
    System.out.println("B.f()");
  }

  public void g() {
    System.out.println("B.g()");
  }
}

