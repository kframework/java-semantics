/*
Simple method test.
  - call a method, no args, return type void, printing a value.
*/

public class method_11_return_void {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    f();
  }

  void f() {
    System.out.println("f()");
  }
}
