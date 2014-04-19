/*
- p2.A(int)
*/

package p2;

public class A extends p1.A {

  public A(int a) {
    super((byte)a);
    System.out.println("p2.A::A(int)");
  }
}
