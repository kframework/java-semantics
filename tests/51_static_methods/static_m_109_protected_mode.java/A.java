package a;

public class A {
  protected void f(byte a) {
    System.out.println("A.f(byte)");
  }

  public void f(long a) {
    System.out.println("A.f(long)");
  }

  protected static void s_g(byte a) {
    System.out.println("A.s_g(byte)");
  }

  public static void s_g(long a) {
    System.out.println("A.s_g(long)");
  }
}
