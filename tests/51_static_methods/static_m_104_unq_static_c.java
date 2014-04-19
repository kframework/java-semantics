/*
First static method is called qualified. It calls another unqualified static method.
*/

public class static_m_104_unq_static_c {
  public static void main(String[] args) {
    A.sf();
    System.out.println("Done!");
  }
}

class A {
  static void sf() {
    System.out.println("A.sf()");
    sg();
  }

  static void sg() {
    System.out.println("A.sg()");
  }
}
