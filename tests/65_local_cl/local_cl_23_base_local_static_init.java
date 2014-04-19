/*
Base class is a local class in a static initializer, traced constructor with no args.
*/

public class local_cl_23_base_local_static_init {
  public static void main(String[] args) {
    System.out.println(O.lb);
    System.out.println("Done!");
  }
}

class O {

  static Object lb;

  static {
    class A {
      A() {
        System.out.println("O.static_init.A.A()");
      }
    }

    class LB extends A {
      LB() {
        System.out.println("O.static_init.LB.LB()");
      }

      public String toString() {return "O.static_init.LB";}
    }

    lb = new LB();
  }
}
