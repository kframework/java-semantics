package p1;

public class A {
  public String toString() {
    return "p1.A";
  }

  public static void test() {
    System.out.println("main.test():");
    System.out.println(new A());
    System.out.println(new B());
  }
}
