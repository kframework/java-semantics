class main {

  int x;

  main(String[] args) {
    x = 5;
    try {
      throw 3;
      System.out.print(x);       // should not print this
    } catch(int y) {
      System.out.println(y);  // should print this
    }
    System.out.println("Done!");
  }
}

public class exceptions10 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 3
// Done!
