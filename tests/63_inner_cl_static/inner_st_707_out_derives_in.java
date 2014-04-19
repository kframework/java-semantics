/*
Outer class derived from the inner class of another class.
  Class A, A.Inner, B < A.Inner. Declare A after B.
  - A.x,
  - Inner.y
  - B.z
  From main print A.x, A.Inner.y, B.y, B.z.
  From B print y, z.
*/

public class inner_st_707_out_derives_in {

  public static void main(String[] args) {
    System.out.println("From main:");
    System.out.println(A.x);
    System.out.println(A.Inner.y);
    System.out.println(B.y);
    System.out.println(B.z);

    System.out.println("From B:");
    B.test();

    System.out.println("Done!");
  }
}

class B extends A.Inner {
  static String z = "B.z";

  static void test() {
    System.out.println(y);
    System.out.println(z);
  }
}

class A {

  static String x = "A.x";

  public static class Inner {
    static String y = "A.Inner.y";
  }
}
