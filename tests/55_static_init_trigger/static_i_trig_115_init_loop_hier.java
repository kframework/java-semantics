/*
B < A. A reads static fields of B. B reads static fields of A.
    Call a static method on B. Default values of B should be observed.
*/

public class static_i_trig_115_init_loop_hier {
  public static void main(String[] args) {
    B.f();
    System.out.println("main:");
    System.out.println("A.v=" + A.v);
    System.out.println("B.v=" + B.v);
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static int v = T.trace(T.trace(B.v) + 5);

}

class B extends A {

  static {
    System.out.println("B.(static init)");
  }

  static int v = T.trace(100);

  static void f() {
    System.out.println("B.f()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
