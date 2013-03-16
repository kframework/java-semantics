/*
Conditional with two refs, one subtype of another.
  Types: A, I2 < I1. I3 < I2, B < A,
  Pairs:
    - A I1
    - I1 A
    - I2 I1
    - I2[] I1[]
    - A Object
    - I3 I1
    - I1 I3
    - B Object
    - Object B
    - B[] Object[]
  Args:
    - A, B, I1, I2, I3, I1[], I2[], B[], Object[], Object.
*/

public class op_cond_type_05_ref_ref {
  public static void main(String[] args) {
    System.out.println("A      I1       : " + f(true ? (A)null      : (I1)null));
    System.out.println("I1     A        : " + f(true ? (I1)null     : (A)null));
    System.out.println("I2     I1       : " + f(true ? (I2)null     : (I1)null));
    System.out.println("I2[]   I1[]     : " + f(true ? (I2[])null   : (I1[])null));
    System.out.println("A      Object   : " + f(true ? (A)null      : (Object)null));
    System.out.println("I3     I1       : " + f(true ? (I3)null     : (I1)null));
    System.out.println("I1     I3       : " + f(true ? (I1)null     : (I3)null));
    System.out.println("B      Object   : " + f(true ? (B)null      : (Object)null));
    System.out.println("Object B        : " + f(true ? (Object)null : (B)null));
    System.out.println("B[]    Object[] : " + f(true ? (B[])null    : (Object[])null));
    System.out.println("Done!");
  }

  static String f(A a) {
    return "A";
  }

  static String f(B a) {
    return "B";
  }

  static String f(I1 a) {
    return "I1";
  }

  static String f(I2 a) {
    return "I2";
  }

  static String f(I3 a) {
    return "I3";
  }

  static String f(I1[] a) {
    return "I1[]";
  }

  static String f(I2[] a) {
    return "I2[]";
  }

  static String f(B[] a) {
    return "B[]";
  }

  static String f(Object[] a) {
    return "Object[]";
  }

  static String f(Object a) {
    return "Object";
  }
}

interface I1 {}
interface I2 extends I1 {}
interface I3 extends I2 {}
class A implements I1 {}
class B extends A {}
