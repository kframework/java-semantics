class main {
  int x, y, z;

  void g() {
    throw new RuntimeException("a");
  }

  void f() {
    g();
  }

  main(String[] args) {
    x = 5;
    y = 10;

    try {
      f();
    } catch(RuntimeException y) {
      System.out.print(y.toString() + " ");
    }
    System.out.print(x+" ");
    System.out.println(y);
    System.out.println("Done!");
  }
}

public class exceptions07 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 15 5 10
// Done!
