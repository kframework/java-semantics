/*
Fields with initializer, refering to superclass static fields/methods.
*/

class A {
  static int a = 5;

  static int f() {
    System.out.println("f()");
    return 3;
  }
}

class B extends A {

  static int b = a + 10;
  static int c = f() + 10;

  static void test() {
    System.out.println("B.test()");
  }
}

public class static_init_31_inheritance {
  public static void main(String[] args) {
    B.test();
    System.out.println("" + B.a + " " + B.b + " " + B.c);
    System.out.println("Done!");
  }
}
