/*
Class init triggering block environment separation.
  Class init is triggered in a block with local var x. Class init initializes the field x.
  Test that the field is assigned to, not the local var.
*/

public class static_i_trig_116_env_separation {
  public static void main(String[] args) {
    int x = 1;
    System.out.println("x = " + x);
    System.out.println("A.x = " + A.x);
    System.out.println("Done!");
  }
}

class A {

  static int x;

  static {
    System.out.println("A.(static init)");
    x = 15;
  }

  static void f() {
    System.out.println("A.f()");
  }
}
