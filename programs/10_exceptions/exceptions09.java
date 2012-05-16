class main {
  int x, y, z;

  void g() {
    throw 15;
  }

  void f() {
    g();
  }

  main(String[] args) {
    x = 5;
    y = 10;

    try {
      f();
    } catch(int y) {
      System.out.print(y+" ");
    }
    System.out.print(x+" ");
    System.out.println(y);
    System.out.println("Done!");
  }
}

public class exceptions09 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 15 5 10
// Done!
