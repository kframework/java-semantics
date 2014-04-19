/*
Static method versions from subclasses are not accessible,
  even when calling them through instance qualifier.
  B < A, B.f() <sig A.f(), call to (A)B.f() have no access to B.f().
*/

public class static_m_110_overload_hier {
  public static void main(String[] args) {
    A a = new B();
    a.sf((byte) 0);
    a.sf((short) 0);
    B b = (B)a;
    b.sf((byte) 0);
    b.sf((short) 0);
    System.out.println("Done!");
  }
}

class A {
  static void sf(long a) {
    System.out.println("A.sf(long)");
  }
}

class B extends A {
  static void sf(byte a) {
    System.out.println("B.sf(byte)");
  }
}
