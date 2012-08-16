/*
35. Multi applicable, polymorphism simple:
    - decl: A: int, long B: int, short.
    - call target: A aa, ab; B bb.
    - arguments: short, int, long.
*/

public class overload_35_multi_appl_poly {

  public static void main(String[] args) {
    A aa = new A(), ab = new B();
    B bb = new B();

    aa.f((short)0);
    aa.f((int)0);
    aa.f((long)0);

    ab.f((short)0);
    ab.f((int)0);
    ab.f((long)0);

    bb.f((short)0);
    bb.f((int)0);
    bb.f((long)0);

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
}

class B extends A {

  void f(int a) {
    System.out.println("B.f(int)");
  }

  void f(short a) {
    System.out.println("B.f(short)");
  }
}
