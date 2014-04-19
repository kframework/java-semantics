/*
Static protected access mode. Test that a static protected method can be
  accessed from a subclass in a different package,
  using an instance qualifier, while a non-static protected cannot.
*/

import a.*;

public class static_m_109_protected_mode extends A {
  public static void main(String[] args) {
    new static_m_109_protected_mode().instanceContext();
    staticContext();

    System.out.println("Done!");
  }

  void instanceContext() {
    A a = new A();
    a.f((byte)0);
    a.f((int)0);
    f((byte)0);
    f((int)0);

    System.out.println();
    a.s_g((byte)0);
    a.s_g((int)0);
    A.s_g((byte)0);
    A.s_g((int)0);
    s_g((byte)0);
    s_g((int)0);
  }

  static void staticContext() {
    System.out.println();
    A.s_g((byte)0);
    A.s_g((int)0);
    s_g((byte)0);
    s_g((int)0);
  }
}
