/*
Interface with a constant initialized with an int value and a traced static initialization.
  Access the constant. Static init should not be triggered.
  Access a non-constant static field. Static init should be triggered.
*/

class const_02_in_interface {
  public static void main(String[] argv) {
    System.out.println("Constant: " + I1.x);
    System.out.println("Regular static: " + I1.y);
    System.out.println("Constant: " + I1.x);
    System.out.println("Done!");
  }
}

interface I1 {
  int x = 3;
  int y = Auxx.traceAndGet(10);
}

class Auxx {
  static int traceAndGet(int a) {
    System.out.println("Trace: " + a);
    return a;
  }
}
