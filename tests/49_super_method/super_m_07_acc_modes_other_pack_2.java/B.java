/*
  - protected B.f(short)
  - B.test(), calls super.f(byte)
*/

package p2;

import p1.*;

public class B extends A {

  String f(short a) {
    return "protected p2.B.f(short)";
  }

  public void test() {
    System.out.println(super.f((byte) 0));
  }
}
