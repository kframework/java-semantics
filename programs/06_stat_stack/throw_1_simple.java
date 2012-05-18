//Testing simple throw.
//Also catch argument shadowing a field with the same name

class main {
  int e = 100;

  main(String[] args) {
    try {
      int x = 5;
      if (x >= 0)
        throw new RuntimeException();
      System.out.print("unreachable");
    } catch(RuntimeException e) {
      System.out.println(e+ " ");   // should print RuntimeException
    }
    System.out.println(e+ " ");     // should print 100
    System.out.println("Done!");
  }
}

public class throw_1_simple {
  public static void main(String[] args) {
    new main(args);
  }
}

// RuntimeException
// 100
// Done!
