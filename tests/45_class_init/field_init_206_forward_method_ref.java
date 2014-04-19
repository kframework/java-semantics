/*
Fields with initializer, refering to methods declared both below and above.
*/

class A {

  int f() {
    System.out.println("f()");
    return 3;
  }

  int a = f();
  int b = g();

  int g() {
    System.out.println("g()");
    return 5;
  }
}

public class field_init_206_forward_method_ref {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("" + a.a + " " + a.b);
    System.out.println("Done!");
  }
}
