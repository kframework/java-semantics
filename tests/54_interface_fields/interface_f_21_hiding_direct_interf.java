/*
Fields hiding involving an interface:
  I2{v} < I1{v}

  Test using class-qualified expression.
*/

public class interface_f_21_hiding_direct_interf {
  public static void main(String[] args) {
    System.out.println(I1.v + " " + I2.v);
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 11;
}

interface I2 extends I1 {
  int v = 12;
}
