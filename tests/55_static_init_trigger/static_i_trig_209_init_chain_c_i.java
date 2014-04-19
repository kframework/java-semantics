/*
Init triggering chain for class/interface mix.
  A, I1. Static init in A accesses field in I1.
  Static sequence of A: {trace} {access of I1} {trace}
*/

public class static_i_trig_209_init_chain_c_i {
  public static void main(String[] args) {
    System.out.println("A.b=" + A.b);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);
}

class A {

  static {
    System.out.println("A.(static init 1)");
  }

  static int b = T.trace(20 + I1.a);

  static {
    System.out.println("A.(static init 2)");
  }

  A() {
    System.out.println("A.A()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
