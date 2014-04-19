/*
  Classes p1.A, p1.A.Inner,
    - p1.A.Inner.toString().
  Refer p1.A.Inner from p1.A, as:
    - p1.A.Inner,
    - A.Inner,
    - Inner
  from:
    - local var declaration
    - field declaration
    - static field declaration
    - parameter declaration
    - C_style array declaration
*/

package p1;

public class A {

  p1.A.Inner i1 = null;
  A.Inner i2 = i1;
  Inner i3 = i2;

  static p1.A.Inner si1 = null;
  static A.Inner si2 = si1;
  static Inner si3 = si2;

  public static void test() {
    p1.A.Inner i1 = new Inner();
    A.Inner i2 = i1;
    Inner i3 = i2;
    f(i1);
    g(si1);
    h(new A().i1);
    p1.A.Inner vi1[] = null;
    A.Inner vi2[] = vi1;
    Inner vi3[] = vi2;
  }

  static void f(p1.A.Inner i1) {
    System.out.println("p1.A.f()");
  }

  static void g(A.Inner i2) {
    System.out.println("p1.A.g()");
  }

  static void h(Inner i3) {
    System.out.println("p1.A.h()");
  }

  public static class Inner {
    public String toString() {
      return "p1.A.Inner";
    }
  }
}
