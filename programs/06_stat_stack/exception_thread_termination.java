// Testing that exception propagates through method calls
// The last line is not printed due to unknown java-prototype definition bug.

public class exception_thread_termination {

  public static void main(String[] args) {
    try {
      try {
        throwEx();

        System.out.println("No exception");
      } finally {
        System.out.println("finally after uncaught exception");
      }
    } finally {
      System.out.println("finally 2 after uncaught exception");
    }
  }

  void throwEx() {
    throw 5;
  }
}

// finally after uncaught exception
// finally 2 after uncaught exception
// Thread terminated with exception: 5
