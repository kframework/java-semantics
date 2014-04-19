/*
Class initialization is triggered once.
Classes A and B. Call a static traced method in each twice, interleaved.
*/

public class static_i_trig_102_two_classes {
  public static void main(String[] args) {
    A.f();
    B.f();
    B.f();
    A.f();

    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static void f() {
    System.out.println("A.f()");
  }
}

class B {

  static {
    System.out.println("B.(static init)");
  }

  static void f() {
    System.out.println("B.f()");
  }
}
