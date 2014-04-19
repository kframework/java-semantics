/*
Class literals involving packages.
  Classes Main, p1.A, p1.B, p2.C
  p1.A imports p2.*.
  From p1.A test .class.getName() for A, B, C, p2.C.
*/

public class class_lit_02_packages {

  public static void main(String[] args) {
    new p1.A().test();
    System.out.println("Done!");
  }
}
