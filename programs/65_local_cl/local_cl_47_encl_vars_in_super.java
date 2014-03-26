/*
Accessing outer local vars in the superclass constructor invocation,
  before local class constructor arguments are accessible.
*/

public class local_cl_47_encl_vars_in_super {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class Base {
  Base(String s) {
    System.out.println("Base: "+ s);
  }
}

class O {

  void test() {

    final int a = 1, b = 20;

    class Local extends Base {
      Local() {
        super("a=" + a + " ,b=" + b);
      }
    }

    new Local();
  }
}
