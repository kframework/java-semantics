/*
Class resolution in array variables / array instantiation.
  Classes p1.A, p2.A.
  Main CU imports p2.A.
  Main contains:
    - local var A[] p2a = new A[]
    - local var p1.A[] p1a1 = new p1.A[]
    - local var p1.A p1a2[] = new p1.A[]
    - local var p1.A[] p1a3 = {...}
*/

import p2.A;

public class packages_56_array_types {

  public static void main(String[] args) {
    A[] p2a = new A[1];
    p1.A[] p1a1 = new p1.A[1];
    p1.A p1a2[] = new p1.A[2];
    p1.A[] p1a3 = {new p1.A(), null};
    X x = new X();

    System.out.println(x.f(p2a[0]));
    System.out.println(x.f(p1a1[0]));
    System.out.println(x.f(p1a2[0]));
    System.out.println(x.f(p1a3[0]));

    System.out.println("Done!");
  }
}

class X {

  String f(A a) {
    return "X.f(p2.A)";
  }

  String f(p1.A a) {
    return "X.f(p1.A)";
  }
}
