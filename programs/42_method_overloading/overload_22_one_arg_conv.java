/*
22. One argument, conversion
  - Definitions: f(long), f(String), f(RuntimeException), f(A)
  - calls types: int, NPE, B (B < A).
*/

public class overload_22_one_arg_conv {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class A {}
class B extends A {}

class main {
  main() {
    f(2);
    f(new NullPointerException("np"));
    f(new B());
  }

  void f(long a) {
    System.out.println("long: " + a);
  }

  void f(String a) {
    System.out.println("String: " + a);
  }

  void f(RuntimeException a) {
    System.out.println("RuntimeException: " + a);
  }

  void f(A a) {
    System.out.println("A: " + a.getClass().getName());
  }
}
