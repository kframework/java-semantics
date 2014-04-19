/*
Multiple inherited field, private in class, public in interface.
  Access mode makes the reference non-ambiguous. Field in the class is instance.
  B < A{private v} ,I{v}.
  Test the following references:
  - B.v,
  - b.v,
  - B{this.b},
  - B{v}.
  - (B static context){v}
  All should point to I.v .
*/

public class f_access_04_multi_inh_priv_pub_2 {
  public static void main(String[] args) {
    B b = new B();
    System.out.println(B.v + " " + b.v + " " + B.staticGetV() + " " + b.getV()
      + " " + b.getThisV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 12;
}

class A {
  private int v = 6;
}

class B extends A implements I1 {

  static int staticGetV() {
    return v;
  }

  int getV() {
    return v;
  }

  int getThisV() {
    return this.v;
  }
}
