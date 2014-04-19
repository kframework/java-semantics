/*
Inheritance of inner class declarations.
  class A, A.Inner, B < A.
  Access Inner from B.
*/

public class inner_st_705_inherit_inner_decl {

  public static void main(String[] args) {
    B.test();

    System.out.println("Done!");
  }
}

class A {

  static String f() {
    return "A.f()";
  }

  public static class Inner {

    static String f() {
      return "A.Inner.f()";
    }
  }
}

class B extends A {
    static void test() {
      System.out.println("Inner.f(): " + Inner.f());
    }
}
