/*
7. Test getAccessMode() rule - access mode not present
  - no method attributes
  - just one attribute - final

  When testing package access mode, we'll also have protected and package versions, protected is more specific, but not accessible. This way we can distinguish between versions.
*/

import a.*;

public class m_access_07_acc_mode_not_spec extends A {
  public static void main(String[] args) {
    A a = new A();

    System.out.println("Calling from package default:");
    a.f((byte)0);
    a.g((byte)0);
    System.out.println();

    B b = new B();
    b.call(a);

    System.out.println("Done!");
  }
}
