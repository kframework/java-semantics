// Testing try with multiple catch clauses

class Exception {
  void Exception() {
  }
}

class Exception2 extends Exception {
  void Exception2() {
  }
}

class Exception3 extends Exception2 {
  void Exception3() {
  }
}

class main {
  void main(string[] args) {
    try {
      try {
        throw new Exception2();

        print("No exception","\n");
      } catch (Exception3 e3) {
        print("caught exception3","\n");
      } finally {
        print("finally after uncaught exception","\n");
      }
    } finally {
      print("finally 2 after uncaught exception","\n");
    }
  }
}

// finally after uncaught exception
// finally 2 after uncaught exception
// Thread terminated with exception: Exception2

