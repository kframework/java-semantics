/*
When evaluation of the qualifier throws an exception, the argument is not evaluated.
    Call a one-arg method with traced argument, on a constructor throwing an exception.
    Catch the exception.
*/

public class method_42_qual_exception_order {

  public static void main(String[] args) {
    try {
      new A(trace(10)).f(trace(2));
      System.out.println("ok");
    } catch (RuntimeException e) {
      System.out.println(e);
    }

    System.out.println("Done!");
  }

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}

class A {
  A(int a) {
    throw new RuntimeException();
  }

  void f(int a) {
    System.out.println("A.f(" + a + ")");
  }
}
