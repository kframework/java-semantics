/*
Superclass have two constructors - one-arg and two-args one. Create anonymous classes for both.
  Traced constructors, nothing more.
*/

public class anonym_cl_35_base_constr_overl {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

abstract class A {
  A(int a) {
    System.out.println("A: a = "+ a);
  }

  A(int a, int b) {
    System.out.println("A: a = "+ a + ", b = " + b);
  }

  abstract void test();
}

class O {

  void test() {
    new A(1) {
      void test() {
        System.out.println("anon1.test()");
      }
    }.test();

    new A(2,3) {
      void test() {
        System.out.println("anon2.test()");
      }
    }.test();
  }
}
