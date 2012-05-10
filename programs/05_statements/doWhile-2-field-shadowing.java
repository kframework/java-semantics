// In this test doWhile body declares a variable
// with the same name as the field. After doWhile completes,
// we should be able to access the field again.

public class main {
  int i = 1;

	void main(String[] args) {
    do {
      int i = 10;
    } while (false);
    System.out.println("After doWhile i = "+ i);
    System.out.println("Done!");
  }
}

// After doWhile i = 1
// Done!
