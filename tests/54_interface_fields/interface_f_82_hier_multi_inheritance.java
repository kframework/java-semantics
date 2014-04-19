/*
Hierarchy of type I3 < (I1,I2). Interfaces all with fields with initializer,
  Fields in I3 refer to I2 then I1 by simple name.
  All initializers print a message. Test that the order is correct.
*/

public class interface_f_82_hier_multi_inheritance {
  public static void main(String[] args) {
    System.out.println("I3.e = " + I3.e);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = Auxx.trace(1);
  int b = Auxx.trace(2);
}

interface I2 {
  int c = Auxx.trace(30);
  int d = Auxx.trace(40);
}

interface I3 extends I1, I2 {
  int e = Auxx.trace(500 + c + b);
}

class Auxx {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
