/*
Hiding and overloading independence. A < B. A.f(int), A.f(long), B.f(int).
  From B, A.f(long) is visible.
*/

public class static_m_113_hiding_overl_indep {
  public static void main(String[] args) {
    A.sf((int)0);
    A.sf((long)0);
    B.sf((int)0);
    B.sf((long)0);

    System.out.println("Done!");
  }
}

class A {
  static void sf(int a) {
    System.out.println("A.sf(int)");
  }

  static void sf(long a) {
    System.out.println("A.sf(long)");
  }
}

class B extends A {

  static void sf(int a) {
    System.out.println("B.sf(int)");
  }
}

