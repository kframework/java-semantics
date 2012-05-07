// Testing continue inside do loop.
// Nothing should change compared to continue in while,
// if continue statement don't occur on first iteration.

class main {

  void main(String[] args) {
    int i=0;
    do {
      int j = i;
      i++;
      if (j % 2 != 0) continue;
      System.out.print(j+" ");
    } while (i<10);
    System.out.println("\n"+ "Done!");
  }
}

// 0 2 4 6 8
// Done!
