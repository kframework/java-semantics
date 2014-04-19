/*
34. Multi applicable, inheritance simple:
  - decl: A: (long) (Object) B:(int) (String) B < A
  - call target: A aa, ab; B bb.
  - arguments: short, int, long, String, Object.
*/

public class overload_34_multi_appl_inherit {

  public static void main(String[] args) {
    A aa = new A(), ab = new B();
    B bb = new B();

    aa.f((short)0);
    aa.f((int)0);
    aa.f((long)0);
    aa.f("");
    aa.f(new Object());

    ab.f((short)0);
    ab.f((int)0);
    ab.f((long)0);
    ab.f("");
    ab.f(new Object());

    bb.f((short)0);
    bb.f((int)0);
    bb.f((long)0);
    bb.f("");
    bb.f(new Object());

    System.out.println("Done!");
  }
}

class A {

  void f(long a) {
    System.out.println("A.f(long)");
  }

  void f(Object a) {
    System.out.println("A.f(Object)");
  }
}

class B extends A {

  void f(int a) {
    System.out.println("B.f(int)");
  }

  void f(String a) {
    System.out.println("B.f(String)");
  }
}
