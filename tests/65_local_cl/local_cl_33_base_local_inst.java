/*
33. Base class LA is a local class in instance context, have traced a constructor with two arguments.
  Local class LB have two constructors:
    - constructor with two arguments - two for the base class args. Calls unqualified superclass constructor.
    - constructor with three arguments - one for qualifier, two for the base class args.
      Calls qualified superclass constructor.
  Local class's test() calls super.test() that prints something from its enclosing class.
  Instantiate 3 LB's:
    - using two-args constructor
    - using three-args constructor, base encloser O.this
    - using three-args constructor, base encloser new O(...)
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

      LB(int a, int b) {
        super(a,b);
      }

      LB(O o, int a, int b) {
        o.super(a,b);
      }

      public String toString() {
        return "O.LB.toString[v = "+v+"]: " + super.toString();
      }
    }

    System.out.println(new LB(1,2));
    System.out.println(new LB(this, 3,4));
    Object obj = O.this;//just for test
    System.out.println(new LB(new O(20), 5,6));
  }
}
