/*
- B.test(), calls super.f(byte)
*/

package p2;

import p1.*;

public class B extends A {
  public void test() {
    System.out.println(super.f((byte) 0));
  }
}
