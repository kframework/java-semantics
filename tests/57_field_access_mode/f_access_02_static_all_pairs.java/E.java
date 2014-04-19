/*
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
  - external class, other package, B-qualified
*/
package b;

import a.*;

public class E {

  public static void testBQualified() {
    System.out.println("(external, package b){B.field}:");

    System.out.println(B.pub_pub);
    //System.out.println(B.pub_pro);
    //System.out.println(B.pub_pac);
    //System.out.println(B.pub_pri);
    //System.out.println(B.pro_pro);
    //System.out.println(B.pro_pac);
    //System.out.println(B.pro_pri);
    //System.out.println(B.pac_pac);
    //System.out.println(B.pac_pri);
    //System.out.println(B.pri_pri);
  }
}
