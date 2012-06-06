// Testing that exception propagates through method calls
// The last line is not printed due to unknown java-prototype definition bug.

public class thread_term_01_throw {

  public static void main(String[] args) {
    System.out.println("before ex");
    if (true) throw new RuntimeException("ex");
    System.out.println("unreachable");
  }
}

// before ex
// Thread terminated with exception: java.lang.RuntimeException: ex
