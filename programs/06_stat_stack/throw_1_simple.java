//Testing simple throw.
//Also catch argument shadowing a field with the same name

class main {
  RuntimeException e = new RuntimeException("field");

  main(String[] args) {
    try {
      int x = 5;
      if (x >= 0)
        throw new RuntimeException("");
      System.out.print("unreachable");
    } catch(RuntimeException e) {
      System.out.println(e.toString() + " ");   // should print RuntimeException
    }
    System.out.println(e.toString() + " ");     // should print RuntimeException: field
    System.out.println("Done!");
  }
}

public class throw_1_simple {
  public static void main(String[] args) {
    new main(args);
  }
}

// java.lang.RuntimeException
// java.lang.RuntimeException: field
// Done!
