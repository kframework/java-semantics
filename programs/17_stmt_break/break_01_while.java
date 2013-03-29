// Testing break inside while loop

public class break_01_while {

  public static void main(String[] args) {
    int i=0;
    while (i<10) {
      if (i >= 5) break;
      System.out.print(i+" ");
      i++;
    }
    System.out.println();
    System.out.println("final i = "+ i);
    System.out.println("Done!");
  }
}

// 0 1 2 3 4
// final i = 5
// Done!
