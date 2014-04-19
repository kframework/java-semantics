/*
Local class instantiating two local classes defined in nested enclosing blocks.
*/

public class local_cl_712_inst_encl_cl_nested {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  Object createLB() {

    class TestLocal1 {

      int param;

      TestLocal1(int param) {
        this.param = param;
      }

      public String toString() {return "O.createLB().TestLocal1 param=" + param;}
    }

    {

      class TestLocal2 {

        int param;

        TestLocal2(int param) {
          this.param = param;
        }

        public String toString() {return "O.createLB().TestLocal2 param=" + param;}
      }

      class LB {
        public String toString() {
          return "LB:\n"
            + new TestLocal1(1).toString() + "\n"
            + new TestLocal2(20).toString() + "\n";
        }
      }

      return new LB();
    }
  }
}
