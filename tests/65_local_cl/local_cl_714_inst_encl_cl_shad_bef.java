/*
Inner class A. After it - local class LA. After - local class A. LA prints A.
  Instantiate LA in the scope of local A, and outside the scope. In both cases it should
  refer to the local A.
*/

public class local_cl_714_inst_encl_cl_shad_bef {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  class A {

    int param;

    A(int param) {
      this.param = param;
    }

    public String toString() {return "O.A param=" + param;}
  }

  void test() {

    class LA {

      int param;

      LA(int param) {
        this.param = param;
      }

      public String toString() {return "LA: " + new A(param);}
    }

    System.out.println("Instantiating LA when A is inner:");
    System.out.println(new LA(1));

    class A {

      int param;

      A(int param) {
        this.param = param;
      }

      public String toString() {return "O.createLB().A param=" + param;}
    }

    System.out.println("Instantiating LA when A is local:");
    System.out.println(new LA(2));
  }
}
