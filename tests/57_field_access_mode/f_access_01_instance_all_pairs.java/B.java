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
  - B, this-qualified
*/
package a;

public class B extends A {
  public    String pub_pub = "B.pub_pub";
  protected String pub_pro = "B.pub_pro";
            String pub_pac = "B.pub_pac";
  private   String pub_pri = "B.pub_pri";
  protected String pro_pro = "B.pro_pro";
            String pro_pac = "B.pro_pac";
  private   String pro_pri = "B.pro_pri";
            String pac_pac = "B.pac_pac";
  private   String pac_pri = "B.pac_pri";
  private   String pri_pri = "B.pri_pri";

  public void testUnqualified() {
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

  public void testThisQualified() {
    System.out.println("B{this.field}:");
    System.out.println(this.pub_pub);
    System.out.println(this.pub_pro);
    System.out.println(this.pub_pac);
    System.out.println(this.pub_pri);
    System.out.println(this.pro_pro);
    System.out.println(this.pro_pac);
    System.out.println(this.pro_pri);
    System.out.println(this.pac_pac);
    System.out.println(this.pac_pri);
    System.out.println(this.pri_pri);
  }
}
