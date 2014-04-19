/*
Base class is a local class in a static method, traced constructor with no args.
*/

public class local_cl_22_base_local_static {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  static Object createLB() {
    class A {
      A() {
        System.out.println("O.createLB().A.A()");
      }
    }

    class LB extends A {
      LB() {
        System.out.println("O.createLB().LB.LB()");
      }

      public String toString() {return "O.createLB().LB";}
    }

    return new LB();
  }
}
