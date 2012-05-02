public class main {
  int x, y, z;

  void g() {
    throw 15;
  }

  void f() {
    g();
  }

  void main(string[] args) {
    x = 5;
    y = 10;

    try {
      f();
    } catch(int y) {
      print(y," ");
    }
    print(x," ");
    print(y,"\n");
    print("Done!","\n");
  }
}

// 15 5 10
// Done!
