/*
  - a.B < A:
    - public f(short)
    - public f(int)
*/

package a;

public class B extends A {

  public void f(short i) {
    System.out.println("B.f(short)");
  }

  public void f(int i) {
    System.out.println("B.f(int)");
  }
}
