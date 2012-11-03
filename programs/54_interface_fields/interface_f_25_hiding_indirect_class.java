/*
Fields hiding involving an interface:
  B < A{v} < I1{v}

  Test using static unqualified and class-qualified expression.
*/

public class interface_f_25_hiding_indirect_class {
  public static void main(String[] args) {
    System.out.println(I1.v + " " + B.v + " " + B.getV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 11;
}

class A implements I1 {
  static int v = 12;
}

class B extends A {

  static int getV() {
    return v;
  }
}
