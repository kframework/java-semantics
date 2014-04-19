/*
Two static and two instance methods in one class. Call all unqualified
  in an instance context.
*/

public class static_m_105_multi_unqualified {
  public static void main(String[] args) {
    new A().test();
    System.out.println("Done!");
  }
}

class A {

  int a = 10;

  void f() {
    System.out.println("A.f(), a="+a);
  }

  static void s_g() {
    System.out.println("A.s_g()");
  }

  void h() {
    System.out.println("A.h()");
  }

  static void s_k() {
    System.out.println("A.s_k()");
  }

  void test() {
    f();
    s_g();
    h();
    s_k();
  }
}
