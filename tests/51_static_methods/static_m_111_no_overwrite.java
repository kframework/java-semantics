/*
Static methods are not overwritten. B < A, A.f() =sig B.f().
  Call to (A)B.f() calls A.f().
*/

public class static_m_111_no_overwrite {
  public static void main(String[] args) {
    A a = new B();
    a.sf(0);
    System.out.println("Done!");
  }
}

class A {
  static void sf(long a) {
    System.out.println("A.sf(long)");
  }
}

class B extends A {
  static void sf(long a) {
    System.out.println("B.sf(long)");
  }
}
