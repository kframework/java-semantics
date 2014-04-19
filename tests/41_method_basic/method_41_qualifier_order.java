/*
Method qualifier is evaluated prior to arguments.
    Call a one-arg method with a traced qualifier and traced argument.
*/

public class method_41_qualifier_order {

  public static void main(String[] args) {
    new A(trace(10)).f(trace(2));

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

  void f(int a) {
    System.out.println("A.f(" + a + ")");
  }
}
