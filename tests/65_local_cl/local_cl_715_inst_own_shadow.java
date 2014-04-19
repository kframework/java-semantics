/*
Local class LA instantiating its own inner class A , that shadows a local class of the enclosing block.
*/

public class local_cl_715_inst_own_shadow {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    class A {

      int param;

      A(int param) {
        this.param = param;
      }

      public String toString() {return "O.A param=" + param;}
    }

    class LA {

      class A {

        int param;

        A(int param) {
          this.param = param;
        }

        public String toString() {return "O.createLB().LA.A param=" + param;}
      }

      int param;

      LA(int param) {
        this.param = param;
      }

      public String toString() {return "LA: " + new A(param);}
    }

    System.out.println("Instantiating LA:");
    System.out.println(new LA(4));
  }
}
