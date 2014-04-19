/*
Static initializer with a local var shadowing a field.
*/

class A {

  static int a = 2;

  static {
    int a = 29;
    System.out.println(a);
  }

  static {
    System.out.println(a);
  }

  static void f() {
    System.out.println(a);
  }
}

public class static_init_25_shadowing {
  public static void main(String[] args) {
    A.f();
    System.out.println("Done!");
  }
}
