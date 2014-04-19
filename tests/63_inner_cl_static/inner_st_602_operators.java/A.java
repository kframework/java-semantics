/*
Inner classes as part of operators.
  - cast operator
  - instanceof operator
  - .class operator
*/

package p1;

public class A {

  public static void test() {
    Inner i1 = new Inner();
    Object o = (Object) i1;
    Inner i2 = (p1.A.Inner) o;
    Inner i3 = (A.Inner) o;
    Inner i4 = (A.Inner) o;
    System.out.println(o instanceof p1.A.Inner);
    System.out.println(o instanceof A.Inner);
    System.out.println(o instanceof Inner);
    System.out.println(p1.A.Inner.class.getName());
    System.out.println(A.Inner.class.getName());
    System.out.println(Inner.class.getName());
  }

  public static class Inner {
    public String toString() {
      return "p1.A.Inner";
    }
  }
}
