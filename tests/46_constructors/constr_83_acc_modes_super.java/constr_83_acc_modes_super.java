/*
Access modes of super() and this():
  - class a.A with constructors:
    - public A(): calls this(byte)
    - private A(byte)
    - package A(short)
    - protected A(int)
    - public A(long)
  - class a.B < A. Calls super(byte).
  - class b.C < A. Calls super(byte).
  - Instantiate A(), B(), C() from main.
*/

import a.*;
import b.*;

public class constr_83_acc_modes_super {
  public static void main(String[] args) {
    System.out.println("new A():");
    new A();
    System.out.println("new a.B():");
    new B();
    System.out.println("new b.C():");
    new C();

    System.out.println("Done!");
  }
}
