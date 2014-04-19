/*
Local class LB1 derived from a local class A that shadows an inner class A of the enclosing class.
  LB2 derived from A after the scope of local A, is thus derived from inner class A.
*/

public class local_cl_721_extends_local_shadow {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  class A {

    public String toString() {return "O.A";}
  }

  void test() {
    {
      class A {
        public String toString() {return "O.test().A";}
      }

      class LB1 extends A {
        public String toString() {
          return "LB1: " + super.toString();
        }
      }

      System.out.println(new LB1());

    }

    class LB2 extends A {
      public String toString() {
        return "LB2: " + super.toString();
      }
    }

    System.out.println(new LB2());
  }
}
