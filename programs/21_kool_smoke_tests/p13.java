class c {
  c() {  }
  void test() {
    System.out.print(-1);
    if (this instanceof c1) System.out.print(1);
    if (this instanceof c2) System.out.print(2);
    if (this instanceof c3) System.out.print(3);
    System.out.println("");
  }
}

class c1 extends c {
  c1() { super(); }
}

class c2 extends c {
  c2() { super(); }
}

class c3 extends c {
  c3() { super(); }
}

class main {
  main(String[] args) {
    (new c()).test();
    (new c1()).test();
    (new c2()).test();
    (new c3()).test();
    System.out.println("Done!");
  }
}

public class p13 {
  public static void main(String[] args) {
    new main(args);
  }
}
