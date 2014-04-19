/*
Super and access modes, other package.
  p2.B < p1.A. Methods:
  - private A.f(byte)
  - package A.f(short)
  - protected A.f(int)
  - public A.f(long)
  - B.test(), calls super.f(byte)
*/

import p2.*;

public class super_m_06_acc_modes_other_pack {

  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}
