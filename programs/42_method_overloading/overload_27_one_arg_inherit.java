/*
27. Overloading, same nr of args, one potentially applicable + inheritance:
  - A: f(int), f(bool) B: f(String), C: f(int[]), C < B < A.
  - calls: C.f(int) f(bool) f(String) f(int[])
*/

public class overload_27_one_arg_inherit {

  public static void main(String[] args) {
    C c = new C();
    c.f(0);
    c.f(true);
    c.f("abc");
    c.f(new int[1]);

    System.out.println("Done!");
  }
}

class A {
  int i;

  void f(int a) {
    System.out.println("A.f(int)");
  }

  void f(boolean a) {
    System.out.println("A.f(boolean)");
  }
}

class B extends A {
  int j;

  void f(String a) {
    System.out.println("B.f(Object)");
  }
}

class C extends B {

  void f(int[] a) {
    System.out.println("C.f(int[])");
  }
}
