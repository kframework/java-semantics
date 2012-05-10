// Test returning objects in methods and then invoking methods on them

class I {
  int val;
  void I(int v) {
    val = v;
  }
  G m1() {
    return (new G(val + 9));
  }
}

class G {
  int a;
  void G(int t) {
    a = t;
  }
  void print2() { System.out.println(a); }
}

public class main {
  void main(String[] args) {
    ((new I(1)).m1()).print2();
    System.out.println("Done!");
  }
}

// 10
// Done!
