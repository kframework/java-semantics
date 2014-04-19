/*
Protected class field hides an interface field. In a derived class, base class field will be chosen.
  Class B < A, A < I1 A: protected static x, I1: public x. Access x in B, also B.x outside B.
*/

public class interface_f_93_field_private_hiding {
  public static void main(String[] args) {
    B.test();
    System.out.println("Outside B: B.x = " + B.x);
    System.out.println("Done!");
  }
}

interface I1 {
  String x = "I1.x";
}

class A implements I1 {
  protected static String x = "A.x";
}

class B extends A {

  static void test() {
    System.out.println("Inside B: x = " + x);
  }
}
