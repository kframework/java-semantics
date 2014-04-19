/*
Conditional with one type null.
  Pairs:
    - A null
    - null A
    - null I
    - null int[]
  args: all types + Object
*/

public class op_cond_type_03_null_ref {
  public static void main(String[] args) {
    System.out.println("A     null : " + f(true ? (A)null : null));
    System.out.println("null  A    : " + f(true ? null : (A)null));
    System.out.println("null  I    : " + f(true ? null : (I)null));
    System.out.println("null  int[]: " + f(true ? null : (int[])null));
    System.out.println("Done!");
  }

  static String f(A a) {
    return "A";
  }

  static String f(I a) {
    return "I";
  }

  static String f(int[] a) {
    return "int[]";
  }

  static String f(Object a) {
    return "Object";
  }
}

class A {}
interface I {}
