// Testing instance of

class C {
  void C() {}
  void test() {
    System.out.print("Instance of class C");
    if (this instanceof C1) System.out.print(1);
    if (this instanceof C2) System.out.print(2);
    if (this instanceof C3) System.out.print(3);
    System.out.print("\n");
  }
}

class C1 extends C {
  void C1() {}
}

class C2 extends C {
  void C2() {}
}

class C3 extends C {
  void C3() {}
}

class main {
  main(String[] args) {
    (new C()).test();
    (new C1()).test();
    (new C2()).test();
    (new C3()).test();
    System.out.println("Done!");
  }
}

public class instanceOf {
  public static void main(String[] args) {
    new main(args);
  }
}

// Instance of class C
// Instance of class C1
// Instance of class C2
// Instance of class C3
// Done!
