/*
Init triggering loop for interfaces.
  I1, A, I2. I1 triggers init of A, that triggers init of I2, that triggers init of I1, A.
  Read a field on I1. Default values of I1 and A should be observed by I2. Tracing.
*/

public class static_i_trig_211_init_loop_c_ii {
  public static void main(String[] args) {
    System.out.println("I1.a=" + I1.a);
    System.out.println("A.b=" + A.b);
    System.out.println("I2.c=" + I2.c);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(T.trace(1) + A.b);
}

class A {

  static {
    System.out.println("A.(static init 1)");
  }

  static int b = T.trace(T.trace(20) + I2.c);

  static {
    System.out.println("A.(static init 2)");
  }

  A() {
    System.out.println("A.A()");
  }
}

interface I2 {
  int c = T.trace(T.trace(300) + I1.a + A.b);
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
