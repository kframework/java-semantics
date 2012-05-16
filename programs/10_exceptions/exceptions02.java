class main {
  main(String[] args) {
    try {
      foo();
    }
    catch(int e) {
      System.out.println(e);  // should print 7
    }
    System.out.println("Done!");
  }

  void foo() {
    try {
      throw 5;
      System.out.print(17);      // should not be printed
    } catch(int e) {
      throw e + 2;    // throws 7
    }
    throw 1;          // should not be reached
  }
}

public class exceptions02 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 7
// Done!
