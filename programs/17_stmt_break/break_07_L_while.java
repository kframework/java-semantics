// Testing simple break inside labeled while loop.

public class break_07_L_while {

  public static void main(String[] args) {
    int i=0;
    label_1:
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
