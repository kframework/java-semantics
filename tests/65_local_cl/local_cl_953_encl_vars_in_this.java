/*
Calling this() with arguments being outer local vars in a local class,
 before local class fields are accessible.
*/

public class local_cl_953_encl_vars_in_this {
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
        this("a = " + a + ", b = " + b);
      }

      Local(String s) {
        System.out.println("Local: "+ s);
      }
    }

    new Local(20);
  }
}
