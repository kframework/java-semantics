/*
Polymorphism for methods with c-like array arguments.
  B < A. Both have methods f(int[]), g(int[]), h(int[])
  Class A: f(int a[]), g(int[] a), h(int a[])
  Class B: f(int[] a), g(int a[]), h(int a[])
  Test that polymorphism works for both.
*/

public class method_38_c_like_arr_poly {
  public static void main(String[] args) {
    A a = new A();
    a.f(null);
    a.g(null);
    a.h(null);
    System.out.println();

    a = new B();
    a.f(null);
    a.g(null);
    a.h(null);
    System.out.println();

    System.out.println("Done!");
  }
}

class A {
  void f(int a[]) {
    System.out.println("A.f(int a[])");
  }

  void g(int[] a) {
    System.out.println("A.g(int[] a)");
  }

  void h(int a[]) {
    System.out.println("A.h(int a[])");
  }
}

class B extends A {
  void f(int[] a) {
    System.out.println("B.f(int[] a)");
  }

  void g(int a[]) {
    System.out.println("B.g(int a[])");
  }

  void h(int a[]) {
    System.out.println("B.h(int a[])");
  }
}
