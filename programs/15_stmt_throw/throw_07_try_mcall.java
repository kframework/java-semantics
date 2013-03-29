// Testing that exception propagates through method calls

class test {

  test() {
    try {
      try {
        throwEx();

        System.out.println("No exception");
      } finally {
        System.out.println("finally after uncaught exception");
      }
    } catch (RuntimeException e) {
      System.out.println("caught exception: " + e.toString());
    }
  }

  void throwEx() {
    throw new RuntimeException();
  }
}

public class throw_07_try_mcall {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

