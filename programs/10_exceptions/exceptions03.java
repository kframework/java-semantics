class main {
  main(String[] args) {
    int x = 1;
    String z;
    try {
      x = x + 1;
      if (true) throw new RuntimeException(""+x);
      x = x/0;
    }     // division by zero unreachable
    catch(RuntimeException y) {
      z = y.getMessage()+"1";
    }
    System.out.println(z);
    System.out.println("Done!");
  }
}

public class exceptions03 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 21
// Done!
