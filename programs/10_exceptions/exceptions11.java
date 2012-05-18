class main {

  main(String[] args) {
    try {
      throw new RuntimeException("a");
    } catch (RuntimeException e) {
      System.out.print(e+" ");
    }
    System.out.println(42);
    System.out.println("Done!");
  }
}

public class exceptions11 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 4 42
// Done!
