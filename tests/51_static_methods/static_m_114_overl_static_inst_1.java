/*
Overloading through a mix of static and instance methods.
  Call from instance context. All methods are accessible.
  Class A:
    - f(byte)
    - static f(short)
    - f(int)
    - static f(long)
    Call via:
      - inside instance method, unqualified.
      - this,
      - instance of A,
    with all param types.
*/

public class static_m_114_overl_static_inst_1 {
  public static void main(String[] args) {
    new A().test();
    System.out.println("Done!");
  }
}

class A {

  void test() {
    System.out.println("instance context unqualified:");
    f((byte)0);
    f((short)0);
    f((int)0);
    f((long)0);

    System.out.println("\nthis.f():");
    this.f((byte)0);
    this.f((short)0);
    this.f((int)0);
    this.f((long)0);

    System.out.println("\na.f():");
    A a = this;
    a.f((byte)0);
    a.f((short)0);
    a.f((int)0);
    a.f((long)0);
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

