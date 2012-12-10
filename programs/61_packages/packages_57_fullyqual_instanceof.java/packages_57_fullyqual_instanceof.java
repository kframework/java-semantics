/*
Class resolution in instanceof.
  Classes p1.A, p2.A. Main CU imports p2.A.
  - Object o1 = new p1.A
  - Object o2 = new p2.A
  - Test instanceof of both objects to A, p1.A, p2.A.
*/

import p2.A;

public class packages_57_fullyqual_instanceof {

  public static void main(String[] args) {
    Object oa1 = new p1.A();
    Object oa2 = new p2.A();

    System.out.println("oa1 instanceof    A: "+ (oa1 instanceof A));
    System.out.println("oa1 instanceof p1.A: "+ (oa1 instanceof p1.A));
    System.out.println("oa1 instanceof p2.A: "+ (oa1 instanceof p2.A));
    System.out.println("oa2 instanceof    A: "+ (oa2 instanceof A));
    System.out.println("oa2 instanceof p1.A: "+ (oa2 instanceof p1.A));
    System.out.println("oa2 instanceof p2.A: "+ (oa2 instanceof p2.A));

    System.out.println("Done!");
  }
}

