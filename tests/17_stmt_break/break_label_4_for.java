// Testing labeled break inside for loop

public class break_label_4_for {

  public static void main(String[] args) {
    int i;
    label_1:
    for(i=0; i<10; i++) {
      if (i >= 5) break label_1;
      System.out.print(i+" ");
    }
    System.out.println();
    System.out.println("final i = "+ i);
    System.out.println("Done!");
  }
}

// 0 1 2 3 4
// final i = 5
// Done!
