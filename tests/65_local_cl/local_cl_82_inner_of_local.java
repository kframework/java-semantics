/*
Class O, method test(). Inside test() local classes LA.
  Class LA defines the inner class InnerOfLA.
  From LA, instantiate two instances of InnerOfLA - one without qualifier, another qualified with a newly
    created instance of LA.
  From InnerOfLA print a field from the enclosing LA.
*/

public class local_cl_82_inner_of_local {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    class LA {
      int param;

      LA(int param) {
        this.param = param;
      }

      public String toString() {return "O.test().LA param=" + param;}

      void test() {
        System.out.println("new InnerOfLA().test():");
        new InnerOfLA().test();
        System.out.println("new LA(22).new InnerOfLA().test():");
        new LA(22).new InnerOfLA().test();
      }

      class InnerOfLA {
        void test() {
          System.out.println("InnerOfLA:" + LA.this.toString());
        }
      }
    }

    new LA(11).test();
  }
}
