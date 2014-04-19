package p1;

import p2.*;

public class B {
  public String toString() {
    return "p1.B";
  }

  public static void test() {
    System.out.println("p1.B.test():");
    System.out.println(new A());
    System.out.println(new B());
  }
}
