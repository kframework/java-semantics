// Testing that return statement propagates through try-catch blocks.

public class return_propagation {

  public static void main(String[] args) {
    test();
    System.out.println("Done!");
  }

  void test() {
    try {
      try {
        return;

        System.out.println("No exception");
      } catch (int e3) {
        System.out.println("caught Exception: "+e3);
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
