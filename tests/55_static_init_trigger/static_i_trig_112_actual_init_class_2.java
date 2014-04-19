/*
When a static member is accessed. Init is triggered for the class that declared
  the member, not the qualifier class.
  C < B{v} < A. Call to C.v. Init in B, A.
*/

public class static_i_trig_112_actual_init_class_2 {
  public static void main(String[] args) {
    System.out.println("" + C.v);
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

  static int v = trace(1);
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
