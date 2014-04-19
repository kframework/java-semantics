/*
Interface init triggered by an unqualified field read from a derived interface.
    I2{c} < I1{a}, c = a + "..." Traced initializers.
*/

public class static_i_trig_214_trigger_by_unq_exp {
  public static void main(String[] args) {
    System.out.println("I2.c= " + I2.c);
    System.out.println("Done!");
  }
}

interface I1 {
  String a = T.trace("I1.a");
}

interface I2 extends I1 {
  String b = T.trace("I2.b");
  String c = T.trace("I2.c: " + a);
}

class T {
  static String trace(String s) {
    System.out.println("trace(" + s + ")");
    return s;
  }
}
