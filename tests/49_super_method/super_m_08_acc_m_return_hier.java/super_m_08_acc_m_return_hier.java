/*
Super and access mode, returning hierarchy.
  p1.C < p2.B < p1.A
  - private A.f(byte)
  - package A.f(short)
  - protected A.f(int)
  - public A.f(long)
  - C.test(), calls super.f(byte)
*/

import p1.*;

public class super_m_08_acc_m_return_hier {

  public static void main(String[] args) {
    new C().test();
    System.out.println("Done!");
  }
}
