/*
Abstract methods and overloading.
  - A:
    - abstract f(int)
    - f(long)
  - B < A:
    - public f(byte)
    - f(int)
  - main:
    - call (A)B.f(byte) - should call f(int)
    - call (B)B.f(byte) - should call f(byte)
*/

abstract class A {
  abstract void f(int i);

  void f(long i) {
    System.out.println("A.f(long)");
  }
}

class B extends A {
  public void f(int i) {
    System.out.println("B.f(int)");
  }

  public void f(byte i) {
    System.out.println("B.f(byte)");
  }
}

public class abstract_02_overload {
  public static void main(String[] args) {
    B b = new B();
    ((A)b).f((byte)0);
    b.f((byte)0);
    System.out.println("Done!");
  }
}
