// Testing continue with label inside simple for loop

public class continue_label_04_for {

  public static void main(String[] args) {
    label_1:
    for(int i=0; i<10; i++) {
      if (i % 2 != 0) continue label_1;
      System.out.print(i+" ");
    }
    System.out.println();
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// Done!
