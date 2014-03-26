/*
Accessing outer local vars in the instance initializer, before local class constructor arguments
  are accessible.
*/

public class local_cl_46_encl_vars_in_inst_init {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 20;

    class Local {
      {
        System.out.println("O.Local.instInit: a="+a + " ,b="+b);
      }
    }

    new Local();
  }
}
