class i {
  int f;
  void i(int v) {
    f = v;
  }
  int get() { return f; }
}

class g {
  i o;
  void g(i o) {
    this.o = o;
  }
  int do1() {
    int f = 9;
    return (o.get());
  }
}

class main {
  main(String[] args) {
    i t = new i(1);
    g y = new g(t);  // passes an oect
    System.out.println(y.do1());
    System.out.println("Done!");
  }
}

public class p11 {
  public static void main(String[] args) {
    new main(args);
  }
}
