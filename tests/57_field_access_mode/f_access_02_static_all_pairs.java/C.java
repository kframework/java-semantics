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
  - C, unqualified
  - C, B-qualified
*/
package a;

public class C extends B {

  public static void testUnqualified() {
    System.out.println("C{field}:");
    System.out.println(pub_pub);
    System.out.println(pub_pro);
    System.out.println(pub_pac);
    //System.out.println(pub_pri);
    System.out.println(pro_pro);
    System.out.println(pro_pac);
    //System.out.println(pro_pri);
    System.out.println(pac_pac);
    //System.out.println(pac_pri);
    //System.out.println(pri_pri);
  }

  public static void testBQualified() {
    System.out.println("C{B.field}:");

    System.out.println(B.pub_pub);
    System.out.println(B.pub_pro);
    System.out.println(B.pub_pac);
    //System.out.println(B.pub_pri);
    System.out.println(B.pro_pro);
    System.out.println(B.pro_pac);
    //System.out.println(B.pro_pri);
    System.out.println(B.pac_pac);
    //System.out.println(B.pac_pri);
    //System.out.println(pri_pri);
  }
}
