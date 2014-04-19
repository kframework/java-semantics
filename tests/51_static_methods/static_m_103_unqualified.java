/*
Static method call unqualified, from an instance method.
*/

public class static_m_103_unqualified {
  public static void main(String[] args) {
    new A().f();
    System.out.println("Done!");
  }
}

class A {
  void f() {
    System.out.println("A.f()");
    s_g();
  }

  static void s_g() {
    System.out.println("A.s_g()");
  }
}
