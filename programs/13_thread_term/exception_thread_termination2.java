// Testing try with multiple catch clauses

class Exception2 extends RuntimeException {
  void Exception2() {
  }
}

class Exception3 extends Exception2 {
  void Exception3() {
  }
}

public class exception_thread_termination2 {
  public static void main(String[] args) {
    try {
      try {
        if (true) throw new Exception2();

        System.out.println("No exception");
      } catch (Exception3 e3) {
        System.out.println("caught exception3");
      } finally {
        System.out.println("finally after uncaught exception");
      }
    } finally {
      System.out.println("finally 2 after uncaught exception");
    }
  }
}

// finally after uncaught exception
// finally 2 after uncaught exception
// Thread terminated with exception: Exception2

