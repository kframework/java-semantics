/*
Init triggering chain for class.
A,B. Static init in B accesses field in A.
Static sequence of B: {trace} {access of A} {trace}
*/

public class static_i_trig_113_init_chain {
  public static void main(String[] args) {
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

  A() {
    System.out.println("B.B()");
  }

  static int v = T.trace(7);
}

class B {

  {
    System.out.println("B.(inst init)");
  }

  static {
    System.out.println("B.(static init 1)");
  }

  static int v = T.trace(A.v + 10);

  static {
    System.out.println("B.(static init 2)");
  }

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
