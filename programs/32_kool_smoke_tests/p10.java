class i {
  int val;

  i(int v) {
    val = v;
  }

  g m1() {
    return (new g(val+9));  // creates and returns an object
  }
}

class g {
  int a;

  g(int t) {
    a = t;
  }

  void print2() { System.out.println(a); }
}

class main {
  main(String[] args) {
    ((new i(1)).m1()).print2();
    System.out.println("Done!");
  }
}

public class p10 {
  public static void main(String[] args) {
    new main(args);
  }
}
