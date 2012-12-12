/*
Class name collision in hierarchy.
  Classes p2.A < p1.A, p1.B < p2.B
  Constructor is traced. toString() prints the class name.
  Instantiate p1.A, p2.A. Print both. Check their instanceof value to p1.A, p2.A
  Also instantiate p1.B, p2.B.
*/

public class packages_61_same_name_in_hier {

  public static void main(String[] args) {
    Object oa1 = new p1.A();
    Object oa2 = new p2.A();
    new p1.B();
    new p2.B();
    System.out.println("oa1: " + oa1);
    System.out.println("oa2: " + oa2);
    System.out.println("oa1 instanceof p1.A: " + (oa1 instanceof p1.A));
    System.out.println("oa1 instanceof p2.A: " + (oa1 instanceof p2.A));
    System.out.println("oa2 instanceof p1.A: " + (oa2 instanceof p1.A));
    System.out.println("oa2 instanceof p2.A: " + (oa2 instanceof p2.A));

    System.out.println("Done!");
  }
}

