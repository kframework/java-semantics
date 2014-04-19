/*
Access to an interface field.
  Through a class extending a class implementing the defining interface.
    Possible expressions:
    - class qualifier,
    - class ref qualifier
    - unqualified in static context
    - unqualified in instance context
    - through "this" in instance context
    - through "super" in instance context
*/

public class interface_f_14_subclass_target {
  public static void main(String[] args) {
    B b = new B();
    System.out.println(B.v + " " + b.v + " " + B.staticGetV() + " " + b.getV()
      + " " + b.getThisV() + " " + b.getSuperV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 12;
}

class A implements I1{}

class B extends A {

  static int staticGetV() {
    return v;
  }

  int getV() {
    return v;
  }

  int getThisV() {
    return this.v;
  }

  int getSuperV() {
    return super.v;
  }
}
