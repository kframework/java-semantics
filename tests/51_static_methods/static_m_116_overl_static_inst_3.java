/*
Overloading through a mix of static and instance methods.
  Inheritnace. Call through super.f()
  Class A:
    - f(int)
    - static f(long)
  Class B < A:
    - f(byte)
    - static f(short)
    Call via:
      - super.f() inside B, with all param types.
*/

public class static_m_116_overl_static_inst_3 {
  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}

class A {

  void f(int a) {
    System.out.println("A.f(int)");
  }

  static void f(long a) {
    System.out.println("A.f(long)");
  }
}

class B extends A {
  void test() {
    System.out.println("super.f():");
    super.f((byte)0);
    super.f((short)0);
    super.f((int)0);
    super.f((long)0);
  }

  void f(byte a) {
    System.out.println("B.f(byte)");
  }

  static void f(short a) {
    System.out.println("B.f(short)");
  }
}

