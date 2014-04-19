/*
Base class is a static inner class, traced constructor with no args.
*/

public class local_cl_21_base_inner_static {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {
  static class A {
    A() {
      System.out.println("O.A.A()");
    }
  }

  A createLB() {
    class LB extends A {
      LB() {
        System.out.println("O.createLB().LB.LB()");
      }

      public String toString() {return "O.createLB().LB";}
    }

    return new LB();
  }
}
