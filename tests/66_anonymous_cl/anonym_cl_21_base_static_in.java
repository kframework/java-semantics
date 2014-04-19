/*
Base class is a static inner class, traced constructor with no args.
*/

public class anonym_cl_21_base_static_in {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  static abstract class A {

    int param;

    A(int param) {
      System.out.println("A: param = "+ param);
      this.param = param;
    }

    abstract void test();
  }

  void test() {
    A a = new A(3) {
      public void test() {
        System.out.println("anon: param = "+ param);
      }
    };

    a.test();
  }
}
