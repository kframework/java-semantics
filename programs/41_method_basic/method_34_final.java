/*
Final method. A simple final method. Null semantics.
*/

public class method_34_final {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    f();
  }

  final void f() {
    System.out.println("f()");
  }
}
