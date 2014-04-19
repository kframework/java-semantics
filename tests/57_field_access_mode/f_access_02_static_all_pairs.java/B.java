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
  - B, unqualified
*/
package a;

public class B extends A {
  static public    String pub_pub = "B.pub_pub";
  static protected String pub_pro = "B.pub_pro";
  static           String pub_pac = "B.pub_pac";
  static private   String pub_pri = "B.pub_pri";
  static protected String pro_pro = "B.pro_pro";
  static           String pro_pac = "B.pro_pac";
  static private   String pro_pri = "B.pro_pri";
  static           String pac_pac = "B.pac_pac";
  static private   String pac_pri = "B.pac_pri";
  static private   String pri_pri = "B.pri_pri";

  public static void testUnqualified() {
    System.out.println("B{field}:");
    System.out.println(pub_pub);
    System.out.println(pub_pro);
    System.out.println(pub_pac);
    System.out.println(pub_pri);
    System.out.println(pro_pro);
    System.out.println(pro_pac);
    System.out.println(pro_pri);
    System.out.println(pac_pac);
    System.out.println(pac_pri);
    System.out.println(pri_pri);
  }
}
