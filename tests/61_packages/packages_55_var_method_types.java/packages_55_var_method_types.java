/*
Class resolution in variable types / method return types.
  Classes p1.A, p2.A.
  Main CU imports p2.A.
  Main contains:
    - local var A,
    - local var p1.A
    - field A
    - field p1.A
    - static field A
    - static field p1.A
    - method f with argument A
    - method f with argument p1.A
      (use those to test local vars and fields by overloading)
    - method with return type A
    - method with return type p1.A
*/

import p2.A;

public class packages_55_var_method_types {

  public static void main(String[] args) {
    A a2 = new A();
    p1.A a1 = new p1.A();
    X x = new X();

    System.out.println(a1);
    System.out.println(a2);
    System.out.println(x.a1);
    System.out.println(x.a2);
    System.out.println(X.sa1);
    System.out.println(X.sa2);
    System.out.println(x.f(a1));
    System.out.println(x.f(a2));
    System.out.println(x.f(x.a1));
    System.out.println(x.f(x.a2));
    System.out.println(x.getP1A());
    System.out.println(x.getP2A());

    System.out.println("Done!");
  }
}

class X {
  A a2 = sa2;
  p1.A a1 = sa1;

  static A sa2 = new p2.A();
  static p1.A sa1 = new p1.A();

  String f(A a) {
    return "X.f(p2.A)";
  }

  String f(p1.A a) {
    return "X.f(p1.A)";
  }

  p1.A getP1A() {
    return a1;
  }

  A getP2A() {
    return a2;
  }
}
