/*
Access of constructors in a new Class(...) expression:
  - class a.A with:
    - public A()
    - private A(byte)
    - package A(short)
    - protected A(int)
    - public A(long)
    - privateNew - calls new A(byte)
  - class a.B < A:
    - packageProtectedNew: calls new A(byte)
  - class b.C < A:
    - protectedNew: calls new A(byte)
  - class a.TestPackage:
    - method packageNew: calls new A(byte)
  - class b.TestPublic:
    - method publicNew: calls new A(byte)
  - main: calls all test methods.
*/

import a.*;
import b.*;

public class constr_84_acc_modes_new {
  public static void main(String[] args) {
    System.out.print("privateNew:          ");
    new A().privateNew();
    System.out.print("packageProtectedNew: ");
    new B().packageProtectedNew();
    System.out.print("protectedNew:        ");
    new C().protectedNew();
    System.out.print("packageNew:          ");
    new TestPackage().packageNew();
    System.out.print("publicNew:           ");
    new TestPublic().publicNew();

    System.out.println("Done!");
  }
}
