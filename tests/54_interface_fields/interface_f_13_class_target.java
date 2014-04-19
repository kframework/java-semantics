/*
Access to an interface field. Through a class implementing directly the defined interface.
    Possible expressions:
    - class qualifier,
    - class ref qualifier
    - unqualified in static context
    - unqualified in instance context
    - through "this" in instance context
*/

public class interface_f_13_class_target {
  public static void main(String[] args) {
    A a = new A();
    System.out.println(A.v + " " + a.v + " " + A.staticGetV() + " " + a.getV()
      + " " + a.getThisV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 12;
}

class A implements I1 {

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
