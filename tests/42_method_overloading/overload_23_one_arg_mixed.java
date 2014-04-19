/*
23. One argument, some methods share compatible values, but for the used calls
  just one method is applicable.
  - Definitions: Definitions: f(long), f(String), f(RuntimeException), f(NPE), f(A)
  - calls types: int, B (B < A).
*/

public class overload_23_one_arg_mixed {

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

  void f(NullPointerException a) {
    System.out.println("NullPointerException: " + a);
  }

  void f(A a) {
    System.out.println("A: " + a.getClass().getName());
  }
}
