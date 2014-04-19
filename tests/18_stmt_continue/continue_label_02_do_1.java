// Testing continue with label inside simple do loop.
// Nothing should change compared to continue in while,
// if continue statement don't occur on first iteration.

public class continue_label_02_do_1 {

  public static void main(String[] args) {
    int i=0;
    label_1:
    do {
      int j = i;
      i++;
      if (j % 2 != 0) continue label_1;
      System.out.print(j+" ");
    } while (i<10);
    System.out.println();
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// Done!
