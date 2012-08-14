/*
26. case ambiguous in one argument, unambiguous in other:
  - f(RuntimeException, String), f(String, RuntimeException)
  - call tyes: (null, String), (null, RuntimeException)
*/

public class overload_26_multi_arg_semiamb {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class A {}
class B extends A {}

class main {
  main() {
    f(null, "abc");
    f(null, new RuntimeException(""));
  }

  void f(RuntimeException a, String b) {
    System.out.println("f(RuntimeException, String)");
  }

  void f(String a, RuntimeException b) {
    System.out.println("f(String, RuntimeException)");
  }
}
