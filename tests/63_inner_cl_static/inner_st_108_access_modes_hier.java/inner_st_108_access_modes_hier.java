/*
Inner class access modes for inherited methods.
  p1.A:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)
  p1.B.InnerB:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)
  Test classes:
    - p1.A.Inner1      < p1.A
    - p1.B.Inner2      < p1.B.InnerB
    - p1.TestP1.Inner3 < p1.A
    - p1.TestP1.Inner4 < p1.B.InnerB
    - TestDef.Inner5   < p1.A
    - TestDef.Inner6   < p1.B.InnerB
  Call f(byte) from:
    - Inner1, ... Inner6
    - from main on targets Inner1, ... Inner6.
*/

public class inner_st_108_access_modes_hier {

  public static void main(String[] args) {
    p1.A.Inner1 inner1 = new p1.A.Inner1();
    p1.B.Inner2 inner2 = new p1.B.Inner2();
    p1.TestP1.Inner3 inner3 = new p1.TestP1.Inner3();
    p1.TestP1.Inner4 inner4 = new p1.TestP1.Inner4();
    TestDef.Inner5 inner5 = new TestDef.Inner5();
    TestDef.Inner6 inner6 = new TestDef.Inner6();

    System.out.println("Tests from inner classes:");
    System.out.println(inner1.test());
    System.out.println(inner2.test());
    System.out.println(inner3.test());
    System.out.println(inner4.test());
    System.out.println(inner5.test());
    System.out.println(inner6.test());

    System.out.println("\nTests from main:");
    System.out.println(inner1.f((byte)0));
    System.out.println(inner2.f((byte)0));
    System.out.println(inner3.f((byte)0));
    System.out.println(inner4.f((byte)0));
    System.out.println(inner5.f((byte)0));
    System.out.println(inner6.f((byte)0));
    System.out.println("Done!");
  }
}
