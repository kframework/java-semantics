// Testing simple continue inside for loop with label.
// Label should not affect continue execution.

public class continue_10_for_label {

  public static void main(String[] args) {
    label_1:
    for(int i=0; i<10; i++) {
      if (i % 2 != 0) continue;
      System.out.print(i+" ");
    }
    System.out.println();
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// Done!
