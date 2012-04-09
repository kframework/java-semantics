// In this test initialisation clause of for declares a variable
// with the same name as the field. After for completes,
// we should be able to access the field again.

public class main {
  int i=-1;

	void main(string[] args) {
    for(int i=0; i<5; i++)
      print(i," ");
    print("\n", "After for i = ", i, "\n");
    print("Done!","\n");
  }
}

// 0 1 2 3 4
// After for i = -1
// Done!
