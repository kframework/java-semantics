/*
Fields hiding involving an interface:
  A{static v, u} < I1{v,u}

  Test using all possible expressions.
*/

public class interface_f_24_hiding_direct_class {
  public static void main(String[] args) {
    A a = new A();
    System.out.print("v instance context: ");
    System.out.println(a.v + " " + ((I1)a).v + " " + a.getV() + " " + a.getThisV());
    System.out.print("v static context  : ");
    System.out.println(A.v + " " + I1.v + " " + A.staticGetV());
    System.out.print("u instance context: ");
    System.out.println(a.u + " " + ((I1)a).u + " " + a.getU() + " " + a.getThisU());

    System.out.println("Done!");
  }
}

interface I1 {
  String v = "I1.v";
  String u = "I1.u";
}

class A implements I1 {

  public static String v = "A.v";
  public String u = "A.u";

  String getV() {
    return v;
  }

  String getThisV() {
    return this.v;
  }

  static String staticGetV() {
    return v;
  }

  String getU() {
    return u;
  }

  String getThisU() {
    return this.u;
  }
}
