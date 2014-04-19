/*
Init triggering chain for class/interface mix.
  I4 < (I2,I3) < I1. Each interface calls a field in the superinterface.
  Init sequence: I1, I2, I3, I4. Call I3-> I1 observes I1's initialized values.
*/

public class static_i_trig_210_init_chain_i_diam {
  public static void main(String[] args) {
    System.out.println("I4.d=" + I4.d);
    System.out.println("I4.c=" + I4.c);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);
}

interface I2 extends I1 {
  int b = a + T.trace(20);
}

interface I3 extends I1 {
  int c = a + T.trace(300);
}

interface I4 extends I2, I3 {
  int d = b + c + T.trace(4000);
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
