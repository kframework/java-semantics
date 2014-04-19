/*
Class initialization is triggered once.
Class A. Call a traced static method twice.
*/

public class static_i_trig_101_class_init_simple {
  public static void main(String[] args) {
    A.f();
    A.f();
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static void f() {
    System.out.println("A.f()");
  }
}
