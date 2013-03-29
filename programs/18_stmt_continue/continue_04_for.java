// Testing continue inside for loop

public class continue_04_for {

  public static void main(String[] args) {
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
