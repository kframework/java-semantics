/*
Fields hiding involving an interface:
  A < I2{v} < I1{v}

  Test using static unqualified and class-qualified expression.
*/

public class interface_f_23_hiding_class_sub_i {
  public static void main(String[] args) {
    System.out.println(I1.v + " " + A.v + " " + A.getV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 11;
}

interface I2 extends I1 {
  int v = 12;
}

class A implements I2{

  static int getV() {
    return v;
  }
}
