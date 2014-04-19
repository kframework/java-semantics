/*
2. Access mode semantics in the context of method overriding.
  Non-public access modes in base class, non-public access modes in derived class,
    all allowed combinations in two contexts derived in the same package
    and derived on other package.

  - a.A:
    - private f11()
    - private f12()
    - private f13()
    - package g21()
    - package g22()
    - package g23()
    - protected h33()
    - public call() - calls all the methods.
  - a.B < A:
    - private f11()
    - package f12()
    - protected f13()
    - package g22()
    - protected g23()
    - protected h33()
  - b.C < A:
    - private f11()
    - package f12()
    - protected f13()
    - private g21()
    - package g22()
    - protected g23()
    - protected h33()
  - A aa, ab, ac. On all three refs execute call().
*/

import a.*;
import b.*;

public class m_access_02_override_2 {
  public static void main(String[] args) {
    A aa = new A();
    A ab = new B();
    A ac = new C();
    aa.call();
    ab.call();
    ac.call();

    System.out.println("Done!");
  }
}
