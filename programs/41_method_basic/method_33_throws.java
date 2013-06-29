/*
Throws clause. A simple method with throws. Null semantics.
*/

public class method_33_throws {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    f();
  }

  void f() throws RuntimeException {
    System.out.println("f()");
  }
}
