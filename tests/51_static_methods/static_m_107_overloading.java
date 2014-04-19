/*
Static method overloading, all versions of the method in one class.
*/

public class static_m_107_overloading {
  public static void main(String[] args) {
    A.sf((byte) 0);
    A.sf((short) 0);
    A.sf((int) 0);
    A.sf((long) 0);
    System.out.println("Done!");
  }
}

class A {
  static void sf(byte a) {
    System.out.println("A.sf(byte)");
  }

  static void sf(long a) {
    System.out.println("A.sf(long)");
  }
}
