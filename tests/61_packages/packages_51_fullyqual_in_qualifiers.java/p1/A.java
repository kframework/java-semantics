/*Class p1.A have a traced constructor, static method f() and static field v.*/

package p1;

public class A {

  public A() {
    System.out.println("p1.A.A()");
  }

  public static void f() {
    System.out.println("p1.A.f()");
  }

  public static int v = 1;
}
