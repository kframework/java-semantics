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
  - external class in the same package, (B b)-qualified
*/
package a;

public class D {

  public void testBObjectQualified() {
    System.out.println("(external, package a){(B b).field}:");

    B b = new B();
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
