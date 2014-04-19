/*
Base class is inner class from another lexical hierarchy, have a traced constructor with no arguments.
  Local class LB have a constructor with one argument - the qualifier of the base class.
  Local class's test() calls super.test() that prints something from its enclosing class.
*/

public class local_cl_31_base_inner_inst {
  public static void main(String[] args) {
    new O2().createLB(new O1(10)).test();
    System.out.println("Done!");
  }
}

class O1 {

  int v;

  O1(int v) {
    this.v = v;
  }

  class A {

    A() {
      System.out.println("O1.A.A()");
    }

    void test() {
      System.out.println("O1.A.test: v = " + v);
    }
  }
}

class O2 {

  O1.A createLB(O1 po1) {
    class LB extends O1.A {
      LB(O1 o1) {
        o1.super();
      }

      void test() {
        System.out.print("O2.LB.test: ");
        super.test();
      }
    }

    return new LB(po1);
  }
}
