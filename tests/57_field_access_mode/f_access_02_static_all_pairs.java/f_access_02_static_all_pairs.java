/*
Static fields access modes in all possible pairs, combined with hiding.
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
  - C, unqualified
  - C, B-qualified
  - external class in the same package, B-qualified
  - external class, other package, B-qualified
*/

import a.*;
import b.*;

public class f_access_02_static_all_pairs {

  public static void main(String[] args) {
    B.testUnqualified();
    C.testUnqualified();
    C.testBQualified();
    D.testBQualified();
    E.testBQualified();
    System.out.println("Done!");
  }
}
