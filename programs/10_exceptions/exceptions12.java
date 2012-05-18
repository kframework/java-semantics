class main {

  main(String[] args) {
    try {
      int a = 15;
    } catch(RuntimeException e) {
      System.out.print(e);   // should not print this
    }
    System.out.println(42);
    System.out.println("Done!");
  }
}

public class exceptions12 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 42
// Done!
