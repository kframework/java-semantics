class a {
  int x;

  a() {
    x=2;
  }

  boolean m1(int x) {
    return (this.x) == x;  // this types, because this.x looked up statically
    // this.x therefore refers to the "int x" field in a
  }

  int c() {
    return x;
  }
}

class b extends a {
  boolean x;

  b() {
    x = false;
  }
}

class main {
  main(String[] args) {
    a[] o= new a[5];
    b[] p = new b[4];
    boolean b;
    o[0] = new a();
    o[1] = new b();
    p[3] = new b();
    p[2] = new b();
    o[3] = o[1];
    o[4] = p[3];
    b = o[4].m1(3);
    if (!b) {
      System.out.println(p[3].c());
    }
    if (!p[2].m1(2)) {
      System.out.println(p[2].c());
    }
    System.out.println("Done!");
  }
}

public class p04 {
  public static void main(String[] args) {
    new main(args);
  }
}
