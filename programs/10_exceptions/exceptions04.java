class main {
  int x = 1;

  main(String[] args) {
    try {
      int x = 5;
      if (true) throw new RuntimeException("" + x);
      int y = x/0;
    }   // division by zero unreachable
    catch(RuntimeException y) {
      y = new RuntimeException(y.getMessage() + "2");
      System.out.print(y.toString() + " ");
    }   // new y here, the one declared by catch
    System.out.println(x);
    System.out.println("Done!");
  }
}

public class exceptions04 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 7 1
// Done!
