// Testing simple continue inside for loop with label.
// Label should not affect continue execution.

public class main {

  void main(string[] args) {
    label_1:
    for(int i=0; i<10; i++) {
      if (i % 2 != 0) continue;
      print(i," ");
    }
    print("\n", "Done!", "\n");
  }
}

// 0 2 4 6 8
// Done!
