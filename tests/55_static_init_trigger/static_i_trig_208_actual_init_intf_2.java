/*
Init is triggered for the interface that declared the member,
not for the qualifier type.
  B{v2} < A < I1{v1}. Call to B.v1. Init of I1 only.
  Call to B.v2 - init of A and B.
*/

public class static_i_trig_208_actual_init_intf_2 {
  public static void main(String[] args) {
    System.out.println("B.a=" + B.a);
    System.out.println("B.a=" + B.a);
    System.out.println("B.c=" + B.c);
    System.out.println("B.c=" + B.c);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);
}

class A implements I1 {

  static int b = T.trace(2);

  static {
    System.out.println("A.(static init)");
  }

  A() {
    System.out.println("A.A()");
  }
}

class B extends A {

  static int c = T.trace(3);

  static {
    System.out.println("B.(static init)");
  }

  B() {
    System.out.println("B.B()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
