package p1;

public class A {

  public static void test() {
    System.out.println(new p1.A.Inner());
    System.out.println(new A.Inner());
    System.out.println(new Inner());
  }

  public static class Inner {
    public String toString() {
      return "p1.A.Inner";
    }
  }
}
