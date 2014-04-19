/*
Class access modes.
  Name collision between imported classes with package mode and local classes with package mode.
  - Main
  - package A
  - package p1.A
  - public p1.B
  - package p2.A
  Main imports p1.*. p1.B imports p2.*;
  Access simple names A and B from Main.test(), and p1.B.test().
*/

import p1.*;

public class packages_72_acc_modes_vs_local {

  public static void main(String[] args) {
    test();
    p1.B.test();

    System.out.println("Done!");
  }

  static void test() {
    System.out.println("main.test():");
    System.out.println(new A());
    System.out.println(new B());
  }
}

