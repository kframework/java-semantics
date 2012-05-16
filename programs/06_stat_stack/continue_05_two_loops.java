// Testing continue inside inner while loop.
// Inner loop lies inside an outer loop with break statement.
// This test exposes an interesting interaction between break and continue
// if continue rules are not correctly implemented.

public class continue_05_two_loops {

  public static void main(String[] args) {
    for (int k=0; k<3; k++) {
      System.out.print(k+": ");
      int i=0;
      while (i<10) {
        int j = i;
        i++;
        if (j % 2 != 0) continue;
        System.out.print(j+" ");
      }
      System.out.println(", break follows");
      break;
    }
    System.out.println("Done!");
  }
}

// 0: 0 2 4 6 8 , break follows
// Done!
