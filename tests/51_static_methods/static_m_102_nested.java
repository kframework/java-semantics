/*
Static method call through Class.f() expression, Inside f(),
  another static method call, Class.g()
*/

public class static_m_102_nested {
  public static void main(String[] args) {
    A.sf();
    System.out.println("Done!");
  }
}

class A {
  static void sf() {
    System.out.println("A.sf()");
    A.sg();
  }

  static void sg() {
    System.out.println("A.sg()");
    A.sh();
  }

  static void sh() {
    System.out.println("A.sh()");
  }
}
