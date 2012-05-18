class main {
  main(String[] args) {
    try {
      foo();
    }
    catch(RuntimeException e) {
      System.out.println(e);  // should print 7
    }
    System.out.println("Done!");
  }

  void foo() {
    try {
      if (true) throw new RuntimeException("a");
      System.out.print(17);      // should not be printed
    } catch(RuntimeException e) {
      throw new RuntimeException(e.getMessage() + "b");    // throws 7
    }
    throw new RuntimeException("unreachable");          // should not be reached
  }
}

public class exceptions02 {
  public static void main(String[] args) {
    new main(args);
  }
}

// ab
// Done!
