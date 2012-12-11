/*
Class resolution in interface extends.
  Interfaces p1.I1, p2.I1, p3.I1.
  Main CU imports p2.I1.
  Interface I2 (same CU) extends I1.
  Interface I3 (same CU) extends p3.I1.
  Test the access to some traced static fields.
*/

import p2.I1;

public class packages_54_interf_extends {
  public static void main(String[] args) {
    System.out.println("I2.vi = " + I2.vi);
    System.out.println("I3.vi = " + I3.vi);
    System.out.println("Done!");
  }
}

interface I2 extends I1 {}
interface I3 extends p3.I1 {}
