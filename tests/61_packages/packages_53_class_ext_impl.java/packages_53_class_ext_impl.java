/*
Class resolution in class extends/implements.
  Classes p1.A, p2.A, interfaces p1.I1, p2.I1.
  Class Test1 imports p1.A, p2.I, extends A implements I.
  Class Test2 (same CU) extends p2.A implements p1.I.
  Test the access to some traced static fields.
*/

import p1.A;
import p2.I;

public class packages_53_class_ext_impl {
  public static void main(String[] args) {
    System.out.println("Test1.va = " + Test1.va);
    System.out.println("Test1.vi = " + Test1.vi);
    System.out.println("Test2.va = " + Test2.va);
    System.out.println("Test2.vi = " + Test2.vi);
    System.out.println("Done!");
  }
}

class Test1 extends A implements I {}
class Test2 extends p2.A implements p1.I {}
