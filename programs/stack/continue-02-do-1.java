// Testing continue inside do loop.
// Nothing should change compared to continue in while,
// if continue statement don't occur on first iteration.

public class main {

  void main(string[] args) {
    int i=0;
    do {
      int j = i;
      i++;
      if (j % 2 != 0) continue;
      print(j," ");
    } while (i<10);
    print("\n", "Done!", "\n");
  }
}

// 0 2 4 6 8
// Done!
