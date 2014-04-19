/*
Base class is inner class from another lexical hierarchy, have a traced constructor with no arguments.
  Anonymous class have a constructor with one argument - the qualifier of the base class.
  Anonymous class's test() calls super.test() that prints something from its enclosing class.
*/

public class anonym_cl_31_base_inner_inst {
  public static void main(String[] args) {
    new O2().test();
    System.out.println("Done!");
  }
}

class O1 {

  int var = 20;

  class A {

    A() {
      System.out.println("A: var = "+ var);
    }

    void test() {
      System.out.println("A.test: var = "+ var);
    }
  }
}

class O2 {

  void test() {

    O1 o1 = new O1();

    O1.A a = o1.new A() {
      public void test() {
        System.out.println("anon:");
        super.test();
      }
    };

    a.test();
  }
}
