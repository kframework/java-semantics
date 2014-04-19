/*
Anonymous class calling a superclass constructor with parameters.
*/

public class anonym_cl_13_super_constr {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

abstract class A {

  int param;

  A(int param) {
    System.out.println("A: param = "+ param);
    this.param = param;
  }

  abstract void test();
}

class O {

  void test() {
    A a = new A(3) {
      public void test() {
        System.out.println("anon: param = "+ param);
      }
    };

    a.test();
  }
}
