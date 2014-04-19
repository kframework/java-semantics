/*
When a static member is accessed. Init is triggered for the class that declared
  the member, not the qualifier class.
  C < B{f()} < A. Call to C.f(). Init in B, A.
*/

public class static_i_trig_111_actual_init_class_1 {
  public static void main(String[] args) {
    C.f();
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
    System.out.println("B.B()");
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

  static void f() {
    System.out.println("B.f()");
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
