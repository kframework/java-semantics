/*
Accessing outer local vars in the instance initializer,
  before local class fields could be initialized from constructor arguments.
*/

public class local_cl_955_encl_vars_in_inst_init {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 10;

    class Local {
      int b;

      Local(int b) {
        this.b = b;
      }

      {
        System.out.println("O.Local.instInit: a = "+a + ", b = "+b);
      }
    }

    new Local(20);
  }
}
