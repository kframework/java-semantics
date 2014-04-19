/*
Fields with initializer, refering to methods declared both below and above.
*/

class A {

  static int f() {
    System.out.println("f()");
    return 3;
  }

  static int a = f();
  static int b = g();

  static int g() {
    System.out.println("g()");
    return 5;
  }
}

public class static_f_init_106_forward_method_ref {
  public static void main(String[] args) {
    System.out.println("" + A.a + " " + A.b);
    System.out.println("Done!");
  }
}
