// Testing try with multiple catch clauses

class Exception2 extends RuntimeException {
  Exception2() {
    super("ex2");
  }
}

class Exception3 extends Exception2 {
  Exception3() {
  }
}

public class thread_term_02_tryCF {
  public static void main(String[] args) {
    try {
      if (true) throw new Exception2();

      System.out.println("No exception");
    } catch (Exception3 e3) {
      System.out.println("caught exception3");
    } finally {
      System.out.println("finally after uncaught exception");
    }
  }
}

// finally after uncaught exception
// Thread terminated with exception: Exception2
