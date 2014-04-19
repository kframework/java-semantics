/*
An inner class A, two blocks each having a local class A.
  Instantiate and print A inside each block and between blocks.
*/

public class local_cl_716_two_local_diff_scope {
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
    {

      class A {

        int param;

        A(int param) {
          this.param = param;
        }

        public String toString() {return "O.createLB().A ver1 param=" + param;}
      }

      System.out.println("Instantiating A in the first block:");
      System.out.println(new A(30));
    }

    System.out.println("Instantiating A between blocks:");
    System.out.println(new A(400));

    {
      class A {

        int param;

        A(int param) {
          this.param = param;
        }

        public String toString() {return "O.createLB().A ver2 param=" + param;}
      }

      System.out.println("Instantiating A in the second block:");
      System.out.println(new A(5000));
    }
  }
}
