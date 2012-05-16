// Testing field initialization and access.
// Works when executed, but does not work when type checked for the
// same reason as in SIMPLE typed: the body of a class allows to
// define only field declarations and methods, no other statements.
// The initialized variable declarations desugar into a variable
// declaration and an assignment statement.

class main {
  int a = 3;

  main(String[] args) {
    System.out.println("a = "+ a);
    System.out.println("Done!");
  }
}

public class field {
  public static void main(String[] args) {
    new main(args);
  }
}

// a = 3
// Done!
