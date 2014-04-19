/*
Inner classes name collision with other language sorts.
  Class A. Members:
    - field x
    - method x()
    - inner type x.
  Distinguish among them by:
    - writing x
    - calling x()
    - instantiating x a = new x();
  Repeat the test from A using name x, and from main using the name A.x.
*/

public class inner_st_709_sorts_name_collision {

  public static void main(String[] args) {
    System.out.println("Test from A:");
    A.test();
    System.out.println("\nTest from main:");
    test();

    System.out.println("Done!");
  }

  static void test() {
    A.x = "x other val";
    System.out.println(A.x);
    System.out.println(A.x());

    A.x a = new A.x();
    System.out.println(a);
  }
}

class A {

  static String x = "A.x";

  static String x() {
    return "A.x()";
  }

  static class x {

    public String toString() {
      return "A.x.toString()";
    }
  }

  static void test() {
    x = "x new val";
    System.out.println(x);
    System.out.println(x());

    x a = new x();
    System.out.println(a);
  }
}
