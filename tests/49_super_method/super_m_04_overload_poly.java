/*
Super in the cotext of overloading and polymorphism.
  B < A
  - A.f(int)
  - A.f(long)
  - B.f(short)
  - B.test() calls super.f(short)
*/

public class super_m_04_overload_poly {

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

  String f(short a) {
    return "B.f(short)";
  }

  void test() {
    System.out.println(super.f((short) 0));
  }
}
