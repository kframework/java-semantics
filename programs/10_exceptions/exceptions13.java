class main {

  main(String[] args) {
    try {
      throw 4;
    } catch (int e) {
      System.out.print(e+" ");
    }
    System.out.println(42);
    System.out.println("Done!");
  }
}

public class exceptions13 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 4 42
// Done!
