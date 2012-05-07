//Testing simple throw.
//Also catch argument shadowing a local variable with the same name.

class Exception {
  Exception(){}
}

class main {
  void main(String[] args) {
    int e = 100;
    try {
      int x = 5;
      if (x >= 0)
        throw new Exception();
      System.out.print("unreachable");
    } catch(Exception e) {
      System.out.println(e+ " ");   // should print Exception
    }
    System.out.println(e+ " ");     // should print 100
    System.out.println("Done!");
  }
}
// Exception
// 100
// Done!
