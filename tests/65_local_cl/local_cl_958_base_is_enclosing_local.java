/*
Deep local class derived from an enclosing local. Outer env vars present.
*/

public class local_cl_958_base_is_enclosing_local {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 10, c = 100;

    class Local {

      Local(int b) {
        System.out.println("Local: a = " + a + ", b = " + b + ", c = " + c);
      }

      void test() {
        int c = 300;

        class DeepLocal extends Local {
          DeepLocal() {
            super(30);
          }
        }

        new DeepLocal();
      }
    }

    new Local(20).test();
  }
}
