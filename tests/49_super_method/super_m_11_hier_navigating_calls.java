/*
Mix of super.method and polymorphism, borrowed from tests for the language KOOL.
*/

class c1 {
  int m1() {
    return m2();
  }
  int m2() { return 13; }
}

class c2 extends c1 {
  int m1() { return 22; }
  int m2() { return 23; }
  int m3() {
    return super.m1();
  }
}

class c3 extends c2 {
  int m1() { return 32; }
  int m2() { return 33; }
}

public class super_m_11_hier_navigating_calls {
  public static void main(String[] args) {
    System.out.println((new c3()).m3());
    System.out.println("Done!");
  }
}
