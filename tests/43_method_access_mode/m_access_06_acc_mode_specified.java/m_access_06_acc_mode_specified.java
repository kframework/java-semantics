/*
6. Test getAccessMode() rule - access mode present
  - one method attribute - access mode, for protected.
  - two method attributes, an access mode and final, access mode is first
  - two method attributes, an access mode and final, access mode is the second

  The tested access mode will be protected, the method will have two versions:
  protected and package. This way we ensure that package is not selected instead of protected.
*/

import a.*;

public class m_access_06_acc_mode_specified {
  public static void main(String[] args) {
    new B();

    System.out.println("Done!");
  }
}

class B extends A {

  B() {
    f((byte)0);
    g((byte)0);
    h((byte)0);
  }
}
