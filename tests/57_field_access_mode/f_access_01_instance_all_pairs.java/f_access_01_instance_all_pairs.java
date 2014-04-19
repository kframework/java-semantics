/*
Instance fields access modes in all possible pairs, combined with hiding.
C < B{v, higher access mode} < A{v, lower access mode}
Concrete pairs:
  - public, public
  - public, protected
  - public, package
  - public, private
  - protected, protected
  - protected, package
  - protected, private
  - package, package
  - package, private
  - private, private
Testing contexts:
  - B, unqualified
  - B, this-qualified
  - C, this-qualified
  - C, (B b)-qualified
  - external class in the same package, (B b)-qualified
  - external class, other package, (B b)-qualified
*/

import a.*;
import b.*;

public class f_access_01_instance_all_pairs {

  public static void main(String[] args) {
    B b = new B();
    b.testUnqualified();
    b.testThisQualified();
    C c = new C();
    c.testThisQualified();
    c.testBObjectQualified();
    D d = new D();
    d.testBObjectQualified();
    E e = new E();
    e.testBObjectQualified();
    System.out.println("Done!");
  }
}
