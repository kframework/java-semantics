// continue label -> labeled block -> matched labeled while.

public class continue_label_11_L_block_L_w {

  public static void main(String[] args) {
    int i=0;
    label_1:
    while (i<10) {
      int j = i;
      i++;
      if (j % 2 != 0) {
        label_2: {
          continue label_1;
        }
      }
      System.out.print(j+" ");
    }
    System.out.println();
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// Done!
