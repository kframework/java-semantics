/*
Static method call qualified with a null reference and an argument.
  No exception occurs, the method is executed.
*/

public class static_m_119_qual_null {
  public static void main(String[] args) {
    A a = null;
    a.sf(A.trace(3));
    System.out.println("Done!");
  }
}

class A {
  static void sf(int a) {
    System.out.println("A.sf()");
  }

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
