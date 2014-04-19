/*
Hierarchy of three classes, all with fields with initializer, static initializers.
  Test that the order is correct. All initializers print a message.

*/

class A {

  static int a = f(1);

  static {
    f(2);
  }

  static {
    f(3);
  }

  static int f(int p) {
    System.out.println("f(" + p + ")");
    return p;
  }
}

class B extends A {

  static {
    f(21);
  }

  static int a = f(22);

  static  {
    f(23);
  }
}

class C extends B {

  static int a = f(31);

  static {
    f(32);
  }

  static  {
    f(33);
  }

  static void f() {
    System.out.println("C.f()");
  }
}

public class static_init_32_hier_order {
  public static void main(String[] args) {
    C.f();
    System.out.println("Done!");
  }
}
