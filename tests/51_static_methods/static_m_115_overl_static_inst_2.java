/*
Overloading through a mix of static and instance methods.
  Call from static context. Only static methods are accessible.
  Class A:
    - f(byte)
    - static f(short)
    - f(int)
    - static f(long)
    Call via:
      - inside static method, unqualified.
      - class name A,
    with param types: short, long. Other ones will give compile-time error.
*/

public class static_m_115_overl_static_inst_2 {
  public static void main(String[] args) {
    A.test();
    System.out.println("Done!");
  }
}

class A {

  static void test() {
    System.out.println("static context unqualified:");
    f((short)0);
    f((long)0);

    System.out.println("\nA.f():");
    A.f((short)0);
    A.f((long)0);
  }

  void f(byte a) {
    System.out.println("A.f(byte)");
  }

  static void f(short a) {
    System.out.println("A.f(short)");
  }

  void f(int a) {
    System.out.println("A.f(int)");
  }

  static void f(long a) {
    System.out.println("A.f(long)");
  }
}

