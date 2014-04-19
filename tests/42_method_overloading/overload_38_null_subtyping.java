/*
38. Subtyping of null.
    - A: int, boolean, Object
    - B: Object[]
    - C: String[]
    - C < B < A
    - Call targets: A a, B b, C c
    - call arguments: null
*/

public class overload_38_null_subtyping {

  public static void main(String[] args) {
    A a = new A();
    B b = new B();
    C c = new C();

    a.f(null);
    b.f(null);
    c.f(null);

    System.out.println("Done!");
  }
}

class A {

  void f(int a) {
    System.out.println("A.f(long)");
  }

  void f(boolean a) {
    System.out.println("A.f(boolean)");
  }

  void f(Object a) {
    System.out.println("A.f(Object)");
  }
}

class B extends A {

  void f(Object[] a) {
    System.out.println("B.f(Object[])");
  }
}

class C extends B {

  void f(String[] a) {
    System.out.println("C.f(String[])");
  }
}
