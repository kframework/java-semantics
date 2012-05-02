// Testing continue inside for loop

public class main {

  void main(string[] args) {
    for(int i=0; i<10; i++) {
      if (i % 2 != 0) continue;
      print(i," ");
    }
    print("\n", "Done!", "\n");
  }
}

// 0 2 4 6 8
// Done!
