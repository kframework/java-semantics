/*
Inner classes as part of type declarations.
  - class extends clause
  - class implements clause
  - interface extends clause
*/

package p1;

public class A {

  public static class Inner {

    public static String id = "p1.A.Inner";

    static String f() {
      return "p1.A.Inner.f()";
    }

    public String toString() {
      return "p1.A.Inner";
    }
  }

  public interface IInt {
    String iid = "p1.A.IInt.id";
  }

  public static class C1 extends p1.A.Inner implements p1.A.IInt {}
  public static class C2 extends A.Inner implements A.IInt {}
  public static class C3 extends Inner implements IInt {}

  public static interface I1 extends p1.A.IInt {}
  public static interface I2 extends A.IInt {}
  public static interface I3 extends IInt {}
}
