/*
(C,D) < B < A. C instantiation, D instantiation. Static tracing.
    A and B should be initialized only once.
*/

public class static_i_trig_110_hier_common_base {
  public static void main(String[] args) {
    new C();
    new D();
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

  A() {
    System.out.println("A.A()");
  }
}

class B extends A {

  {
    System.out.println("B.(inst init)");
  }

  static {
    System.out.println("B.(static init)");
  }

  B() {
    System.out.println("B.B()");
  }
}

class C extends B {

  {
    System.out.println("C.(inst init)");
  }

  static {
    System.out.println("C.(static init)");
  }

  C() {
    System.out.println("C.C()");
  }
}

class D extends B {

  {
    System.out.println("D.(inst init)");
  }

  static {
    System.out.println("D.(static init)");
  }

  D() {
    System.out.println("D.D()");
  }
}
