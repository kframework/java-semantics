/*
Fields hiding involving an interface:
  B < A{static v, u} < I1{v,u}

  Test using all possible expressions, from the context B.
*/

public class interface_f_25_hiding_indirect_class {
  public static void main(String[] args) {
    B b = new B();
    System.out.print("v instance context: ");
    System.out.println(b.v + " " + b.getV() + " " + b.getThisV() + " " + b.getSuperV());
    System.out.print("v static context  : ");
    System.out.println(B.v + " " + B.staticGetV());
    System.out.print("u instance context: ");
    System.out.println(b.u + " " + b.getU() + " " + b.getThisU() + " " + b.getSuperU());

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
}

class B extends A {

  String getV() {
    return v;
  }

  String getThisV() {
    return this.v;
  }

  String getSuperV() {
    return super.v;
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

  String getSuperU() {
    return super.u;
  }
}
