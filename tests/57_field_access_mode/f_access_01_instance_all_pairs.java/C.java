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
  - C, this-qualified
  - C, (B b)-qualified
*/
package a;

public class C extends B {

  public void testThisQualified() {
    System.out.println("C{this.field}:");
    System.out.println(this.pub_pub);
    System.out.println(this.pub_pro);
    System.out.println(this.pub_pac);
    //System.out.println(this.pub_pri);
    System.out.println(this.pro_pro);
    System.out.println(this.pro_pac);
    //System.out.println(this.pro_pri);
    System.out.println(this.pac_pac);
    //System.out.println(this.pac_pri);
    //System.out.println(pri_pri);
  }

  public void testBObjectQualified() {
    System.out.println("C{(B b).field}:");

    B b = this;
    System.out.println(b.pub_pub);
    System.out.println(b.pub_pro);
    System.out.println(b.pub_pac);
    //System.out.println(b.pub_pri);
    System.out.println(b.pro_pro);
    System.out.println(b.pro_pac);
    //System.out.println(b.pro_pri);
    System.out.println(b.pac_pac);
    //System.out.println(b.pac_pri);
    //System.out.println(pri_pri);
  }
}
