/*
Interface initialization is triggered once.
Interfaces I1, I2. Read a field twice in both, interleaved. Trace.
*/

public class static_i_trig_202_two_i {
  public static void main(String[] args) {
    System.out.println("I1.v= " + I1.v);
    System.out.println("I2.v= " + I2.v);
    System.out.println("I1.v= " + I1.v);
    System.out.println("I2.v= " + I2.v);
    System.out.println("Done!");
  }
}

interface I1 {
  int v = T.trace(1);
}

interface I2 {
  int v = T.trace(2);
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
