/*
4. Same as test 3 but now we have three overloaded methods
  in A instead of one: f(), g(), and h(). This is an extensive test of access modes
  accessibility.

  The difference is the access mode of the most specific version:
    - f(byte) is package
    - g(byte) is protected
    - h(byte) is public

All methods with all versions are the following:

    - private f(short)
    - package f(byte)
    - protected f(int)
    - public f(long)

    - private g(short)
    - package g(int)
    - protected g(byte)
    - public g(long)

    - private h(short)
    - package h(int)
    - protected h(long)
    - public h(byte)
*/

import a.*;
import b.*;

public class m_access_04_acc_modes {
  public static void main(String[] args) {
    A arg = new A();
    A a = new A();
    B b = new B();
    C c = new C();
    D d = new D();
    a.call(arg);
    a.call();
    b.call(arg);
    c.call(arg);
    c.call();
    d.call(arg);

    System.out.println("Done!");
  }
}
