class main {

  main(String[] args) {
    try {
      int b = 1;
      try {
        b = 2;
      } catch(RuntimeException a) {
        System.out.print(2);     // should not print this
      }
      throw new RuntimeException("a");
    } catch(RuntimeException b) {
      System.out.println(1);  // should print this
    }
    System.out.println("Done!");
  }
}

public class exceptions13 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 1
// Done!
