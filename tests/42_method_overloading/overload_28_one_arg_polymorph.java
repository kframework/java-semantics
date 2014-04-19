/*
28. Overloading, same nr of args, one potentially applicable + polymorphism.
  - A: (int), f(String) B: f(int), f(bool).
  - A aa, ab; B bb. Call all accessible members.
*/

public class overload_28_one_arg_polymorph {

  public static void main(String[] args) {
    A aa = new A(), ab = new B();
    B bb = new B();

    aa.f(0);
    aa.f("");
    ab.f(0);
    ab.f("");
    bb.f(0);
    bb.f("");
    bb.f(false);

    System.out.println("Done!");
  }
}

class A {
  int i;

  void f(int a) {
    System.out.println("A.f(int)");
  }

  void f(String a) {
    System.out.println("A.f(String)");
  }
}

class B extends A {
  int j;

  void f(int a) {
    System.out.println("B.f(int)");
  }

  void f(boolean a) {
    System.out.println("B.f(boolean)");
  }
}

