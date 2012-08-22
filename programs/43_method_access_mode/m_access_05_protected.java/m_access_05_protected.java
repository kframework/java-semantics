/*
5. Protected access mode and overloading.
  Test that protected methods cannot be called using a qualified expression line a.f(),
  even if a is the same object as this. Base and derived classes are necessary in
  different packages, so that protected mode cannot be interpreted ans package.
  Case when protected can be interpreted as package is covered in the test 4.
    The program should test 3 cases:
    - this.f() - ok
    - a.f(), a =/= this - protected is inaccessible.
    - a.f(), a == this - protected is inaccessible.
*/

//todo
import a.*;
import b.*;

public class m_access_05_protected {
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
