/*
  - a.A:
    - protected abstract f(short)
    - public abstract f(int)
    - public f(long)
*/

package a;

public abstract class A {
  protected abstract void f(short i);
  public abstract void f(int i);

  public void f(long i) {
    System.out.println("A.f(long)");
  }
}
