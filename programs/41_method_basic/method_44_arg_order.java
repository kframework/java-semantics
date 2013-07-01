/*
Method arguments are evaluated left-to-right.
    Call a method with 5 arguments, all different and traced.
*/

public class method_44_arg_order {

  public static void main(String[] args) {
    new A(trace(10)).f(trace(1), trace(2), trace(3), trace(4), trace(5));

    System.out.println("Done!");
  }

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}

class A {
  A(int a) {
    System.out.println("A.A(" + a + ")");
  }

  void f(int a, int b, int c, int d, int e) {
    System.out.println("A.f(" + a + "," + b + "," + c + "," + d + "," + e + ")");
  }
}
