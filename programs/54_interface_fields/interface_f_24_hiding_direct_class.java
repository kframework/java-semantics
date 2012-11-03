/*
Fields hiding involving an interface:
  A{v} < I1{v}

  Test using static unqualified and class-qualified expression.
*/

public class interface_f_24_hiding_direct_class {
  public static void main(String[] args) {
    System.out.println(I1.v + " " + A.v + " " + A.getV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 11;
}

class A implements I1 {

  static int v = 12;

  static int getV() {
    return v;
  }
}
