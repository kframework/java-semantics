// In this test doWhile body declares a variable
// with the same name as the field. After doWhile completes,
// we should be able to access the field again.

public class main {
  int i = 1;

	void main(string[] args) {
    do {
      int i = 10;
    } while (false);
    print("After doWhile i = ", i, "\n");
    print("Done!","\n");
  }
}

// After doWhile i = 1
// Done!
