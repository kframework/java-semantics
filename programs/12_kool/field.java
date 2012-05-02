// Testing field initialization and access.
// Works when executed, but does not work when type checked for the
// same reason as in SIMPLE typed: the body of a class allows to
// define only field declarations and methods, no other statements.
// The initialized variable declarations desugar into a variable
// declaration and an assignment statement.

class main {
  int a = 3;

  void main(string[] args) {
    print("a = ", a, "\n");
    print("Done!","\n");
  }
}

// a = 3
// Done!
