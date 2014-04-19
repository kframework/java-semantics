/*
Class init triggering a cyclic initialization request.
A,B,C, C triggers init of B, that triggers init of A, that triggers init of C.
Call a static method on C. Default values of C should be observed. Tracing.
*/

public class static_i_trig_114_init_loop_no_hier {
  public static void main(String[] args) {
    C.f();
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static int v = T.trace(C.v + 3);

  static {
    System.out.println("C.v=" + C.v);
  }

}

class B {

  static {
    System.out.println("B.(static init)");
  }

  static int v = T.trace(A.v + 20);
}

class C {

  static {
    System.out.println("C.(static init)");
  }

  static int v = T.trace(B.v + 100);

  static {
    System.out.println("C.v=" + C.v);
  }

  static void f() {
    System.out.println("C.f()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
