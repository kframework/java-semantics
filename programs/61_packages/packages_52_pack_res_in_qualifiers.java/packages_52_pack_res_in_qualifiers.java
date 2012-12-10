/*
Testing instantiation, static method access and static field access from all possible
  package-resolution modes.
  class Main. Target classes A, p1.B, p1.C, p2.C, p3.A, p3.C.
  All of them contain a traced constructor, a static method f() and a field v.
  class Main imports p1.B and p2.*. Test constructor, method call and field read through qualifiers:
    - A
    - B
    - C
    - p3.A,
    - p3.C
*/

import p1.B;
import p2.*;

public class packages_52_pack_res_in_qualifiers {
  public static void main(String[] args) {
    //A
    new A();
    A.f();
    System.out.println("A.v = " + A.v);
    A.v = 7;
    System.out.println("Executed A.v = 7.");
    System.out.println("A.v = " + A.v);
    System.out.println();

    //B
    new B();
    B.f();
    System.out.println("B.v = " + B.v);
    B.v = 7;
    System.out.println("Executed B.v = 7.");
    System.out.println("B.v = " + B.v);
    System.out.println();

    //C
    new C();
    C.f();
    System.out.println("C.v = " + C.v);
    C.v = 7;
    System.out.println("Executed C.v = 7.");
    System.out.println("C.v = " + C.v);
    System.out.println();

    //p3.A
    new p3.A();
    p3.A.f();
    System.out.println("p3.A.v = " + p3.A.v);
    p3.A.v = 7;
    System.out.println("Executed p3.A.v = 7.");
    System.out.println("p3.A.v = " + p3.A.v);
    System.out.println();

    //p3.C
    new p3.C();
    p3.C.f();
    System.out.println("p3.C.v = " + p3.C.v);
    p3.C.v = 7;
    System.out.println("Executed p3.C.v = 7.");
    System.out.println("p3.C.v = " + p3.C.v);
    System.out.println();

    System.out.println("Done!");
  }
}
