/*
Super and access modes, same package.
  p1.B < p1.A. Methods:
  - private A.f(byte)
  - package A.f(short)
  - protected A.f(int)
  - public A.f(long)
  - B.test(), calls super.f(byte)
*/

import p1.*;

public class super_m_05_acc_modes_same_pack {

  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}
