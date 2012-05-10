public class main {
  int x, y, z;

  void g() {
    throw 15;
  }

  void f() {
    g();
  }

  void main(String[] args) {
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

// 15 5 10
// Done!
