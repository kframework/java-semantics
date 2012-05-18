class main {

  int e = 100;

  main(String[] args) {
    try {
      int x = 5;
      if (x >= 0)
        throw new RuntimeException(""+x+2);
      System.out.print(20);      // should not be printed
    } catch(RuntimeException e) {
      System.out.print(e.getMessage() + " ");   // should print 7
    }
    System.out.print(e + " ");     // should print 100
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
