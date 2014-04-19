/*
Calling super() from a local class, where the base class is also a local class.
*/

public class local_cl_952_cons_super_base_local {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 10;

    class BaseLocal {
      BaseLocal(int b) {
        System.out.println("BaseLocal: a = " + a + ", b = " + b);
      }
    }

    class Local extends BaseLocal {
      Local() {
        super(20);
      }
    }

    new Local();
  }
}
