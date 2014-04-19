/*
Init is triggered for the interface that declared the member,
not for the qualifier type.
  I3 < I2{v} < I1. Access I3.v. Only I2 init is performed.
*/

public class static_i_trig_207_actual_init_intf_1 {
  public static void main(String[] args) {
    System.out.println("I3.b=" + I3.b);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);
}

interface I2 extends I1 {
  int b = T.trace(2);
}

interface I3 extends I2 {
  int c = T.trace(3);
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
