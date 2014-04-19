/*
Instantiating a local class that shadows an inner class of the enclosing class.
  Instantiate and print the said class before the definition of the Local,
  in the scope of the local class, and after it.
*/

public class local_cl_713_inst_encl_cl_shadow {
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
      System.out.println("Before local:");
      System.out.println(new A(1));

      class A {

        int param;

        A(int param) {
          this.param = param;
        }

        public String toString() {return "O.createLB().A param=" + param;}
      }

      System.out.println("Local:");
      System.out.println(new A(2));

    }

    System.out.println("After local:");
    System.out.println(new A(3));
  }
}
