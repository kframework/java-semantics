/*
Base class is inner class from another lexical hierarchy, have traced a constructor with two arguments.
  Local class have a constructor with three arguments - one for qualifier, two for the base class args.
  Local class's test() calls super.test() that prints something from its enclosing class.
*/

public class local_cl_32_base_in_inst_3_arg {
  public static void main(String[] args) {
    new O2().createLB().test();
    System.out.println("Done!");
  }
}

class O1 {

  int v,a,b;

  O1(int v) {
    this.v = v;
  }

  class A {

    A(int a, int b) {
      O1.this.a = a;
      O1.this.b = b;
      System.out.println("O1.A.A()");
    }

    void test() {
      System.out.println("O1.A.test: v=" + v + ", a=" + a + ", b=" + b);
    }
  }
}

class O2 {

  O1.A createLB() {
    class LB extends O1.A {

      LB(O1 o1, int a, int b) {
        o1.super(a,b);
      }

      void test() {
        System.out.print("O2.LB.test: ");
        super.test();
      }
    }

    return new LB(new O1(10),1,2);
  }
}
