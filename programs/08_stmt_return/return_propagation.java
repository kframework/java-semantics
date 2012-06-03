// Testing that return statement propagates through try-catch blocks.

public class return_propagation {

  public static void main(String[] args) {
    test();
    System.out.println("Done!");
  }

  static void test() {
    try {
      try {
        if (true) return;

        System.out.println("No exception");
      } catch (RuntimeException e3) {
        System.out.println("caught Exception: " + e3);
      } finally {
        System.out.println("finally after return");
      }
    } finally {
      System.out.println("finally 2 after return");
    }
  }
}

// finally after return
// finally 2 after return
// Done!
