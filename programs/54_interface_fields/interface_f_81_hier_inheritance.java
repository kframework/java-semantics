/*
I2 < I1. Fields with initializer, refering to superinterface static fields
  by simple name. Test that superclass fields are initialized.
*/

public class interface_f_81_hier_inheritance {
  public static void main(String[] args) {
    System.out.println("I2.b = " + I2.c);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = Aux.trace(1);
  int b = Aux.trace(2);
}

interface I2 extends I1 {
  int c = Aux.trace(10);
  int d = Aux.trace(a + 10);
}

class Aux {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
