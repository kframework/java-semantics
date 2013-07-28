/*
Base class LA is a local class in instance context, have traced a constructor with two arguments.
  Local class LB have a constructor with three arguments - one for qualifier, two for the base class args.
  Local class's test() calls super.test() that prints something from its enclosing class.
  Instantiate two LB's - one with encloser O.this, other with another encloser.
*/

public class local_cl_33_base_local_inst {
  public static void main(String[] args) {
    new O(10).testLB();
    System.out.println("Done!");
  }
}

class O {

  int v;

  O(int v) {
    this.v = v;
  }

  void testLB() {

    class LA {

      int a,b;

      LA(int a, int b) {
        this.a = a;
        this.b = b;
        System.out.println("O1.LA.LA()");
      }

      public String toString() {
        return "O.LA.toString: v=" + v + ", a=" + a + ", b=" + b;
      }
    }

    class LB extends LA {

      LB(O o, int a, int b) {
        o.super(a,b);
      }

      public String toString() {
        return "O.LB.toString[v = "+v+"]: " + super.toString();
      }
    }

    System.out.println(new LB(this, 1,2));
    System.out.println(new LB(new O(20), 3,4));
  }
}
