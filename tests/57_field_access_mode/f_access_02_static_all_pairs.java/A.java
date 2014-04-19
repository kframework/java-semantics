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
*/
package a;

public class A {
  static public    String pub_pub = "A.pub_pub";
  static public    String pub_pro = "A.pub_pro";
  static public    String pub_pac = "A.pub_pac";
  static public    String pub_pri = "A.pub_pri";
  static protected String pro_pro = "A.pro_pro";
  static protected String pro_pac = "A.pro_pac";
  static protected String pro_pri = "A.pro_pri";
  static           String pac_pac = "A.pac_pac";
  static           String pac_pri = "A.pac_pri";
  static private   String pri_pri = "A.pri_pri";
}
