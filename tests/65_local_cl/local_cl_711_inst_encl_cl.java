/*
Local class instantiating another local class from the same enclosing block.
*/

public class local_cl_711_inst_encl_cl {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  Object createLB() {

    class TestLocal {

      int param;

      TestLocal(int param) {
        this.param = param;
      }

      public String toString() {return "O.createLB().TestLocal param=" + param;}
    }

    class LB {
      public String toString() {
        return new TestLocal(5).toString();
      }
    }

    return new LB();
  }
}
