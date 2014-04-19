/*
Class access modes. Packages p1, p2. Classes:
  - Main
  - public p1.A
  - package p1.B
  - package p2.A
  - public p2.B
  Class main imports p1.*; p2.*;
  Access simple names A and B from Main.test(), p1.A.test() and p2.B.test().
*/

import p1.*;
import p2.*;

public class packages_71_class_access_modes {

  public static void main(String[] args) {
    test();
    p1.A.test();
    p2.B.test();

    System.out.println("Done!");
  }

  static void test() {
    System.out.println("main.test():");
    System.out.println(new A());
    System.out.println(new B());
  }
}

