/*
  - C.test(), calls super.f(byte)
*/

package p1;

import p2.*;

public class C extends B {

  public void test() {
    System.out.println(super.f((byte) 0));
  }
}
