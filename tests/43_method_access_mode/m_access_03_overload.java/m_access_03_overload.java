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
    - public call(b.C): calls f(byte) on b.C object
  - call all seven call() methods.
*/

import a.*;
import b.*;

public class m_access_03_overload {
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
    d.call(c);

    System.out.println("Done!");
  }
}
