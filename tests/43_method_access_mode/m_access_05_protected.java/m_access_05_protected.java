/*
5. Protected access mode and overloading.
  Test that protected methods cannot be called using a qualified expression line a.f(),
  even if a is the same object as this. Base and derived classes are necessary in
  different packages, so that protected mode cannot be interpreted as package mode.
  Case when protected can be interpreted as package is covered in the test 4.
    The program should test 3 cases:
    - this.f() - ok
    - a.f(), a =/= this - protected is inaccessible.
    - a.f(), a == this - protected is inaccessible.
*/

import a.*;
import b.*;

public class m_access_05_protected {
  public static void main(String[] args) {
    A arg = new A();
    C c = new C();

    c.call();
    c.call(arg);
    c.call(c);

    System.out.println("Done!");
  }
}
