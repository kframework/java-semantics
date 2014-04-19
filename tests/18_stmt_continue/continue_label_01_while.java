// Testing continue with label inside simple while loop

public class continue_label_01_while {

  public static void main(String[] args) {
    int i=0;
    label_1:
    while (i<10) {
      int j = i;
      i++;
      if (j % 2 != 0) continue label_1;
      System.out.print(j+" ");
    }
    System.out.println();
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// Done!
