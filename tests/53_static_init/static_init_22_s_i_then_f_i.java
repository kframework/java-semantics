/*
Static initializer, then field initializer, initializing the same field.
*/

class A {

  static {
    System.out.println("inst init begin, a = " + A.a);
    a = 3;
  }

  static int a = 2;

  static void f() {
    System.out.println("A.f(): a = " + a);
  }
}

public class static_init_22_s_i_then_f_i {
  public static void main(String[] args) {
    A.f();
    System.out.println("Done!");
  }
}
