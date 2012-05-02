// Testing that exception propagates through method calls
// The last line is not printed due to unknown java-prototype definition bug.

public class main {

  void main(string[] args) {
    try {
      try {
        throwEx();

        print("No exception","\n");
      } finally {
        print("finally after uncaught exception","\n");
      }
    } finally {
      print("finally 2 after uncaught exception","\n");
    }
  }

  void throwEx() {
    throw 5;
  }
}

// finally after uncaught exception
// finally 2 after uncaught exception
// Thread terminated with exception: 5
