/*
Inner class method overloads outer class method with the same name.
  class O: void f(String)
  class O.A: void f(int)
  main: call from A: f(int), f(String)
*/

public class inner_in_81_inner_overl_outer {
  public static void main(String[] args) {
    new O().new A().test();
    System.out.println("Done!");
  }
}

class O {

  void f(String s) {
    System.out.println("O.f(String)");
  }

  class A {

    void f(int i) {
      System.out.println("O.A.f(int)");
    }

    void test() {
      //f("a");

      /*error: method f in class O.A cannot be applied to given types;
        f("a");
        ^
        required: int
        found: String
        reason: actual argument String cannot be converted to int by method invocation conversion
      */

      f(0);
    }
  }
}
