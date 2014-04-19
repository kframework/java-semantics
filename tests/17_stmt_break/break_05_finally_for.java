// Testing break inside try/finally inside for. Finally block should execute
// after break was executed

public class break_05_finally_for {

  public static void main(String[] args) {
    int i;
    for(i=0; i<10; i++) {
      try {
        if (i >= 5) break;
        System.out.print(i);
      } finally {
        System.out.print("-"+ i+ " ");
      }
    }
    System.out.println();
    System.out.println("final i = "+ i);
    System.out.println("Done!");
  }
}

// 0-0 1-1 2-2 3-3 4-4 -5
// final i = 5
// Done!
