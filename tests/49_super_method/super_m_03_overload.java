/*
Super in the context of overloading, simple.
  B < A
  Methods:
  - A.f(int)
  - A.f(long)
  - B.test() calls super.f(short)
*/

public class super_m_03_overload {

  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}

class A {
  String f(int a) {
    return "A.f(int)";
  }

  String f(long a) {
    return "A.f(long)";
  }
}

class B extends A {
  void test() {
    System.out.println(super.f((short) 0));
  }
}
