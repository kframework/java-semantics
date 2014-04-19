/*
Class initialization conditions.
Class A all four triggers, only one static init.
*/

public class static_i_trig_106_all_triggers {
  public static void main(String[] args) {
    A.trace(2);
    A.a = 7;
    System.out.println("" + A.a);
    new A();
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static int a = trace(1);

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }

  A() {
    System.out.println("A.A()");
  }
}
