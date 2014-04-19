/*
Basic interface test.
  Interface I1:
    - void f()
    - void g()
  - class A < I1:
    - implements f, g
  - main:
    - call f, g through interface and through A.
*/

public class interface_21_basic {
  public static void main(String[] args) {
    I1 i1 = new A();
    i1.f();
    i1.g();

    System.out.println("Done!");
  }
}

interface I1 {
  public void f();
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

