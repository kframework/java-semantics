class main {
  main(String[] args) {
    int e = 100;
    try {
      int x = 5;
      if (x >= 0)
        throw x+2;
      System.out.print(20);      // should not be printed
    } catch(int e) {
      System.out.print(e+ " ");   // should print 7
    }
    System.out.print(e+ " ");     // should print 100
    System.out.println(10);
    System.out.println("Done!");
  }
}

public class exceptions01 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 7 100 10
// Done!
