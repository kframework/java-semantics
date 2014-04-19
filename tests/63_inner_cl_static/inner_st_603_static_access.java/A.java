/*
Inner classes as qualifiers for static members access.
  - qualifier of static field read
  - qualifier of static field write
  - qualifier of static method call
  - qualifier of interface field read
*/

package p1;

public class A {

  public static void test() {
    p1.A.Inner.id = "other id";
    A.Inner.id = "id 3";
    Inner.id = "id 4";

    System.out.println(p1.A.Inner.id);
    System.out.println(A.Inner.id);
    System.out.println(Inner.id);
    System.out.println(p1.A.Inner.f());
    System.out.println(A.Inner.f());
    System.out.println(Inner.f());
    System.out.println(p1.A.IInt.id);
    System.out.println(A.IInt.id);
    System.out.println(IInt.id);
  }

  public static class Inner {

    static String id = "p1.A.Inner";

    static String f() {
      return "p1.A.Inner.f()";
    }

    public String toString() {
      return "p1.A.Inner";
    }
  }

  public interface IInt {
    String id = "p1.A.IInt.id";
  }
}
