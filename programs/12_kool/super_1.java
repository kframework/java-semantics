// Testing dynamic method dispatch and super

class C1 {
  void C1() {}

  int m1() {
    return(m2());
  }
  int m2() { return 13; }
}

class C2 extends C1 {
  void C2() {}

  int m1() { return 22; }
  int m2() { return 23; }
  int m3() {
    return(super.m1());
  }
}

class C3 extends C2 {
  void C3() {}
  int m1() { return 32; }
  int m2() { return 33; }
}

class main {
  main(String[] args) {
    C3 o3 = new C3();
    System.out.println(o3.m3());
    System.out.println("Done!");
  }
}

public class super_1 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 33
// Done!
