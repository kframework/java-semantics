// In this test initialisation clause of for declares a variable
// with the same name as the field. After for completes,
// we should be able to access the field again.
// This test also ensures that break don't disrupt <env> cell restoration
// after for terminates.

public class main {
  int i=-1;

	void main(string[] args) {
    for(int i=0; i<5; i++) {
      print(i," ");
      if (i == 3) break;
    }
    print("\n", "After for i = ", i, "\n");
    print("Done!","\n");
  }
}

// 0 1 2 3
// After for i = -1
// Done!
