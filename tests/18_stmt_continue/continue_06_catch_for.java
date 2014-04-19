// Testing continue inside try/catch inside for. Try./catch should not affect
// continue behavior, even if both interact with the same stack.

public class continue_06_catch_for {

  public static void main(String[] args) {
    int i;
    for(i=0; i<10; i++) {
      try {
        if (i % 2 != 0) continue;
      } catch(RuntimeException ex) {
        System.out.print("never reached");
      }
      System.out.print(i+" ");
    }
    System.out.println();
    System.out.println("final i = "+ i);
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// final i = 10
// Done!
