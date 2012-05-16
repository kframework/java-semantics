class main {

  main(String[] args) {
    try {
      15;
    } catch(int e) {
      System.out.print(e);   // should not print this
    }
    System.out.println(42);
    System.out.println("Done!");
  }
}

public class exceptions14 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 42
// Done!
