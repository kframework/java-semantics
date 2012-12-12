/*
Simple super call.
  B < A
  - A.f()
  - B.test(), calls super.f()
*/

public class super_m_01_simple {

  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}

class A {
  String f() {
    return "A.f()";
  }
}

class B extends A {
  void test() {
    System.out.println(super.f());
  }
}
