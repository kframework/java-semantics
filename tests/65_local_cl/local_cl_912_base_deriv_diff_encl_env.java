/*
Base class and derived class with different local environments. Same outer local var
  referred in base and derived of the same object should yield different result.
*/

public class local_cl_912_base_deriv_diff_encl_env {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 10, c = 100;

    class Local1 {
      public String toString() {
        return "O.test().Local: a="+a + " ,b="+b + " ,c="+c;
      }
    }

    class Local2 {

      void test() {
        final int a = 2, b = 20;

        class DeepLocal extends Local1 {
          public String toString() {

            int a = 3;

            return "O.test().Local2.test().DeepLocal: a="+a + " ,b="+b + " ,c="+c
                + "\n" + "super.toString():\n"
                + super.toString();
          }
        }

        System.out.println("Instantiating DeepLocal from Local2:");

        System.out.println(new DeepLocal());
      }
    }

    System.out.println("O.test(): a="+a + " ,b="+b + " ,c="+c+"\n");

    new Local2().test();
  }
}
