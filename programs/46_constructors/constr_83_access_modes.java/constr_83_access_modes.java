/*
super() access modes.
  - class a.A with four constructors:
    - private A(byte)
    - package A(short)
    - protected A(int)
    - public A(long)
  - class a.B < A. Instantiate with super(byte).
  - class b.C < A. Instantiate with super(byte).
  - class a.Test1. Instantiate A with byte.
  - Instantiate Test1, A, B, C from main with byte.
*/

import a.*;
import b.*;

public class constr_83_access_modes {
  public static void main(String[] args) {
    new Test1();
    new A((byte)0);
    new B();
    new C();

    System.out.println("Done!");
  }
}
