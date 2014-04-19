/*
Static method call through Class.f() expression.
*/

public class static_m_101_qualified {
  public static void main(String[] args) {
    A.sf();
    System.out.println("Done!");
  }
}

class A {
  static void sf() {
    System.out.println("A.sf()");
  }
}
