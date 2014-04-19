/*
Base class is inner class from the same lexical hierarchy, have traced a constructor with two arguments.
  Anonymous class have a constructor with two arguments, one for each base argument.
  Anonymous class's test() calls super.test() that prints something from its enclosing class.
*/

public class anonym_cl_32_base_in_with_args {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  int a, b;

  class A {

    A(int a, int b) {
      System.out.println("A: a = "+ a + ", b = "+ b);
      O.this.a = a;
      O.this.b = b;
    }

    void test() {
      System.out.println("A.test: a = "+ a + ", b = "+ b);
    }
  }

  void test() {

    A a = new A(1, 2) {
      public void test() {
        System.out.println("anon:");
        super.test();
      }
    };

    a.test();
  }
}
