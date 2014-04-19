package p2;

public class B {
  public String toString() {
    return "p2.B";
  }

  public static void test() {
    System.out.println("p2.B.test():");
    System.out.println(new A());
    System.out.println(new B());
  }
}
