/*
Static member access from inner class to outer class by simple name.
  B < A, B.Inner.
  Members:
    - static A.a,
    - static B.b,
    - static B.f()
  Call them as A.a, B.b, B.f(), a, b, f() from B.Inner.
*/

public class inner_st_301_static {

  public static void main(String[] args) {
    new B.Inner().test();
    System.out.println("Done!");
  }
}

class A {
  static String a = "A.a";
}

class B extends A {

  static String b = "B.b";

  static String f() {
    return "B.f()";
  }

  public static class Inner {
    public void test() {
      System.out.println("B.Inner:");
      System.out.println(A.a + " " + B.b + " " + B.f());
      System.out.println(a + " " + b + " " + f());
    }
  }
}
