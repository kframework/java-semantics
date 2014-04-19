/*
Instantiate a local class from an instance initializer.
*/

public class local_cl_918_new_local_in_inst_init {
  public static void main(String[] args) {
    O o = new O();
    o.test(1);
    o.test(2);
    System.out.println("Done!");
  }
}

class O {

  void test(final int a) {

    class Local1 {
      void test() {
        System.out.println("Local1: a="+a);
      }
    }

    class Local2 {

      Local1 local1 = new Local1();

      void test() {
        System.out.println("Local2: a="+a);
        System.out.println("field Local1:");
        local1.test();
        System.out.println();
      }
    }

    new Local2().test();
  }
}
