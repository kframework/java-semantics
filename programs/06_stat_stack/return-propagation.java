// Testing that return statement propagates through try-catch blocks.

public class main {

  void main(string[] args) {
    test();
    print("Done!", "\n");
  }

  void test() {
    try {
      try {
        return;

        print("No exception","\n");
      } catch (int e3) {
        print("caught Exception: ",e3,"\n");
      } finally {
        print("finally after return","\n");
      }
    } finally {
      print("finally 2 after return","\n");
    }
  }
}

// finally after return
// finally 2 after return
// Done!
