// Testing break inside for loop

public class main {

  void main(string[] args) {
    int i;
    for(i=0; i<10; i++) {
      if (i >= 5) break;
      print(i," ");
    }
    print("\n", "final i = ", i, "\n");
    print("Done!", "\n");
  }
}

// 0 1 2 3 4
// final i = 5
// Done!
