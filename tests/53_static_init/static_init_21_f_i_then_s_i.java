/*
Field with initializer, then static initializer, initializing the same field.
*/

class A {
  static int a = 2;

  static {
    System.out.println("inst init begin, a = " + a);
    a = 3;
  }

  static void f() {
    System.out.println("A.f(): a = " + a);
  }
}

public class static_init_21_f_i_then_s_i {
  public static void main(String[] args) {
    A.f();
    System.out.println("Done!");
  }
}
