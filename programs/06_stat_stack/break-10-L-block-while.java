// Testing simple break inside a labeled block, inside simple while loop.
// Labeled block should not affect break execution.

public class main {

  void main(String[] args) {
    int i=0;
    while (i<10) {
      label_1: {
        if (i >= 5) break;
      }
      System.out.print(i+" ");
      i++;
    }
    System.out.println("\n"+ "final i = "+ i);
    System.out.println("Done!");
  }
}

// 0 1 2 3 4
// final i = 5
// Done!
