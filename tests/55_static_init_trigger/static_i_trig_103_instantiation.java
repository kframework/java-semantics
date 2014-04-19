/*
Class initialization conditions.
Class A instantiation.
*/

public class static_i_trig_103_instantiation {
  public static void main(String[] args) {
    new A();
    new A();
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  A() {
    System.out.println("A.A()");
  }
}
