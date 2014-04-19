/*
Static field access from inner class to outer class by simple name.
  B < A, B.Inner.
  Members:
    - static A.a,
    - static B.b,
  Call them as A.a, B.b, a, b from B.Inner from static and instance context.
  In both contexts read the values, write them by simple name
  and then read again by simple name.
*/

public class inner_st_301_simple_outer_field {

  public static void main(String[] args) {
    new B.Inner().test();
    B.Inner.staticTest();
    System.out.println("Done!");
  }
}

class A {
  static String a = "A.a";
}

class B extends A {

  static String b = "B.b";

  public static class Inner {
    public void test() {
      System.out.println("B.Inner instance ct:");
      System.out.println(A.a + " " + B.b);
      System.out.println(a + " " + b);

      a = "a_val_2";
      b = "b_val_2";
      System.out.println(a + " " + b);
    }

    public static void staticTest() {
      System.out.println("B.Inner static ct:");
      System.out.println(A.a + " " + B.b);
      System.out.println(a + " " + b);

      a = "a_val_3";
      b = "b_val_3";
      System.out.println(a + " " + b);
    }
  }
}
