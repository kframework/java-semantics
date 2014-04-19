/*
Super and access modes, other package,
  methods in derived class make no difference.
  p2.B < p1.A. Methods:
  - private A.f(byte)
  - package A.f(short)
  - protected A.f(int)
  - public A.f(long)
  - protected B.f(short)
  - B.test(), calls super.f(byte)
*/

import p2.*;

public class super_m_07_acc_modes_other_pack_2 {

  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}
