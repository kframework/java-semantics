/*
Init triggering loop for interfaces.
  B{c,f()} < abstract A{b} < I1{a,f()}. All static and instance inits traced.
    B instance init accesses A fields, A static init accesses I1 fields. A static instantiates B
    (after accessing I1).
    Call new A().f();
    Observe static init order: A, I1, B. B observes partially
    statically initialized A, but fully instance initialized.
*/

public class static_i_trig_212_init_loop_intf_hier {
  public static void main(String[] args) {
    new B().f();
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);

  void f();
}

abstract class A implements I1 {

  static {
    System.out.println("A.(static init 1)");
  }

  static int b = T.trace(20) + I1.a;
  static B objB = new B();

  static int c = T.trace(30) + I1.a;

  int d = 600;

  static {
    System.out.println("A.(static init 2)");
  }

  {
    System.out.println("A.(inst init)");
  }

  A() {
    System.out.println("A.A()");
  }
}

class B extends A {

  static {
    System.out.println("B.(static init)");
  }

  {
    System.out.println("B.(inst init)");
  }

  B() {
    System.out.println("B.B(), b="+b+", c="+c+", d="+d);
  }

  public void f() {
    System.out.println("B.f()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
