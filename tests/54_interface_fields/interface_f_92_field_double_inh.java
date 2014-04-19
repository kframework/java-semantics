/*
Interface field hides a private field inherited from superclass.
  Testing that interface field will be chosen.
  Class B < A,I. A: private static x, I: public x. Access x in B, also B.x outside B.
*/

public class interface_f_92_field_double_inh {
  public static void main(String[] args) {
    B.test();
    System.out.println("Outside B: B.x = " + B.x);
    System.out.println("Done!");
  }
}

interface I1 {
  String x = "I1.x";
}

class A {
  private static String x = "A.x";
}

class B extends A implements I1 {
  static void test() {
    System.out.println("Inside B: x = " + x);
  }
}
