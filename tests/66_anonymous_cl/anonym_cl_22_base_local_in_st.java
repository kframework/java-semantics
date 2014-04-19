/*
Base class is a local class in a static method, traced consturctor with no args.
*/

public class anonym_cl_22_base_local_in_st {
  public static void main(String[] args) {
    O.test();
    System.out.println("Done!");
  }
}

class O {

  static void test() {

    final int local = 10;

    abstract class A {

      int param;

      A(int param) {
        System.out.println("A: param = "+ param + " local = "+ local);
        this.param = param;
      }

      abstract void test();
    }

    A a = new A(3) {
      public void test() {
        System.out.println("anon: param = "+ param);
      }
    };

    a.test();
  }
}
