// Testing that exception propagates through method calls
// The last line is not printed due to unknown java-prototype definition bug.

class test {
  void throwEx() {
    throw new RuntimeException("ex");
  }
}

public class thread_term_03_mcall {

  public static void main(String[] args) {
    System.out.println("before ex");
    new test().throwEx();
    System.out.println("unreachable");
  }
}

// before ex
// Thread terminated with exception: java.lang.RuntimeException: ex
