/*
Instantiating a local class from itself.
*/

public class local_cl_956_instantiate_itself {
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

        new Local(30);
      }
    }

    new Local(20).test();
  }
}
