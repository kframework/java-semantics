/*
    - a.A  public f, less specific.
    - a.A: package f
*/

package a;

public class A {
  public void f(long a) {
    System.out.println(" - a.A.f(long) ");
  }

  void f(int a) {
    System.out.println(" - a.A.f(int)  ");
  }
}
