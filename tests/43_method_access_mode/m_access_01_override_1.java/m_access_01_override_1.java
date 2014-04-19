/*
1. Access mode semantics in the context of method overriding.
  Testing that a class may have multiple methods
  with the same signature but not in an overloading relation,
  due to private/package access mode.

  - a.A:
    - private f()
    - package g()
    - protected h()
    - public k()
    - public call() - calls all four other methods.
  - a.B < A:
    - public f()
    - public g()
    - public h()
    - public k()
  - b.C < A:
    - public f()
    - public g()
    - public h()
    - public k()
  - A aa, ab, ac. On all three refs execute call().
*/

import a.*;
import b.*;

public class m_access_01_override_1 {
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
