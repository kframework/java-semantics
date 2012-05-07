// Testing that exception propagates through method calls

class main {

  void main(String[] args) {
    try {
      try {
        throwEx();

        System.out.println("No exception");
      } finally {
        System.out.println("finally after uncaught exception");
      }
    } catch (int e) {
      System.out.println("caught exception: "+e);
    }
    System.out.println("Done!");
  }

  void throwEx() {
    throw 5;
  }
}

// finally after uncaught exception
// caught exception: 5
// Done!
