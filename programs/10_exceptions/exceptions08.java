class main {

  int x;

  main(String[] args) {
    x = 5;
    try {
      if (true) throw new RuntimeException("a");
      System.out.print(x);       // should not print this
    } catch(RuntimeException y) {
      System.out.println(y.toString());  // should print this
    }
    System.out.println("Done!");
  }
}

public class exceptions08 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 3
// Done!
