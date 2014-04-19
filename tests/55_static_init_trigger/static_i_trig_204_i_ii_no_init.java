/*
Class/interface init do not trigger superinterface init.
I3 < I2, I1. Access a field in I3. Then access a field
in I1, then in I2. Observe init order: I3, I1, I2.
*/

public class static_i_trig_204_i_ii_no_init {
  public static void main(String[] args) {
    System.out.println("I3.c=" + I3.c);
    System.out.println("I1.a=" + I1.a);
    System.out.println("I2.b=" + I2.b);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);
}

interface I2 {
  int b = T.trace(2);
}

interface I3 extends I1, I2 {
  int c = T.trace(3);
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
