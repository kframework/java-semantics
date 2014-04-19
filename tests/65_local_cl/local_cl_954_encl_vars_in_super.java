/*
Calling super() with arguments being outer local vars in a local class,
  before local class fields are accessible.
*/

public class local_cl_954_encl_vars_in_super {
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

    final int a = 1, b = 10;

    class Local extends Base {
      Local(int b) {
        super("a = " + a + ", b = " + b);
      }
    }

    new Local(20);
  }
}
