/*
Instantiating an enclosing local class from a deep local class.
*/

public class local_cl_957_inst_enclosing_local {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 10;

    class Local {

      Local(int b) {
        System.out.println("Local: a = " + a + ", b = " + b);
      }

      void test() {
        int a = 3;

        class DeepLocal {
          void test() {
            new Local(30);
          }
        }

        new DeepLocal().test();
      }
    }

    new Local(20).test();
  }
}
