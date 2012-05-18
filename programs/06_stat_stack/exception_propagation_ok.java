// Testing that exception propagates through method calls

public class exception_propagation_ok {

  public static void main(String[] args) {
    try {
      try {
        throwEx();

        System.out.println("No exception");
      } finally {
        System.out.println("finally after uncaught exception");
      }
    } catch (RuntimeException e) {
      System.out.println("caught exception: "+e);
    }
    System.out.println("Done!");
  }

  static void throwEx() {
    throw new RuntimeException("");
  }
}

// finally after uncaught exception
// caught exception: RuntimeException
// Done!
