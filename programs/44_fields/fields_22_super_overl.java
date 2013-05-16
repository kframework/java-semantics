/*
B < A. Call to B: f(super.x) where A.x and B.x are of different types, f() overloaded.
*/

class A {
  int x = 100;
}

class B extends A {
  boolean x = false;

  String f(int x) {
    return "B.f(int)";
  }

  String f(boolean x) {
    return "B.f(boolean)";
  }

  void test() {
    System.out.println("f(this.x)  = " + f(this.x));
    System.out.println("f(super.x) = " + f(super.x));
  }
}

public class fields_22_super_overl {
  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}
