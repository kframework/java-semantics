/*
Class init triggers superclass init.
B < A. Static and instance init tracing. Call static method on B.
*/

public class static_i_trig_109_hier_s_meth_call {
  public static void main(String[] args) {
    B.f();
    B.f();
    System.out.println("Done!");
  }
}

class A {

  {
    System.out.println("A.(inst init)");
  }

  static {
    System.out.println("A.(static init)");
  }

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}

class B extends A {

  {
    System.out.println("B.(inst init)");
  }

  static {
    System.out.println("B.(static init)");
  }

  static void f() {
    System.out.println("B.f()");
  }
}
