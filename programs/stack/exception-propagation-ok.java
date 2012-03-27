// Testing that exception propagates through method calls

public class main {

  void main(string[] args) {
    try {
      try {
        throwEx();

        print("No exception","\n");
      } finally {
        print("finally after uncaught exception","\n");
      }
    } catch (int e) {
      print("caught exception: ",e,"\n");
    }
  }

  void throwEx() {
    throw 5;
  }
}

// finally after uncaught exception
// caught exception: 5
