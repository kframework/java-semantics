/*
  - package C.f(short)
  - C.test(), calls super.f(byte)
*/

package p1;

import p2.*;

public class C extends B {

  String f(short a) {
    return "package p1.C.f(short)";
  }

  public void test() {
    System.out.println(super.f((byte) 0));
  }
}
