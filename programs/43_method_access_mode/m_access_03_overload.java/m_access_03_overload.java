/*
3. Access mode semantics in the context of method overloading. Test of accessibility.
  Multiple overloaded methods, all potentially applicable, with more specific versions having a
  more restricted access specifier. In all contexts, the most restricted accessible method will
  be called.

  - a.A:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)
    - public call(a.A): calls f(byte) on a.A object
    - public call(): calls f(byte) locally
  - a.B:
    - public call(a.A): calls f(byte) on a.A object
  - b.C < A:
    - public call(a.A): calls f(byte) on a.A object
    - public call(): calls f(byte) locally
  - b.D:
    - public call(a.A): calls f(byte) on a.A object
  - call all six call() methods.
*/

import a.*;
import b.*;

public class m_access_03_overload {
  public static void main(String[] args) {
    A a = new A();
    B b = new B();
    C c = new C();
    D d = new D();
    a.call(a);
    a.call();
    b.call(a);
    c.call(a);
    c.call();
    d.call(a);

    System.out.println("Done!");
  }
}
