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
  public    String pub_pub = "A.pub_pub";
  public    String pub_pro = "A.pub_pro";
  public    String pub_pac = "A.pub_pac";
  public    String pub_pri = "A.pub_pri";
  protected String pro_pro = "A.pro_pro";
  protected String pro_pac = "A.pro_pac";
  protected String pro_pri = "A.pro_pri";
            String pac_pac = "A.pac_pac";
            String pac_pri = "A.pac_pri";
  private   String pri_pri = "A.pri_pri";
}
