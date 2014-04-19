package p1;

public class A {

  public static void test() {
    System.out.println(new C());
    System.out.println(new B.C());
    System.out.println(new p2.B.C());
  }

  public static class C {
    public String toString() {
      return "p1.A.C";
    }
  }
}
