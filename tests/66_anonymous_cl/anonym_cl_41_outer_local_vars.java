/*
Anonymous class accessing:
  - a field of the enclosing class
  - a local var that shadows a field of the enclosing class
  - its own field, that shadows a local var of the enclosing block
  - a constant from the base interface
*/

public class anonym_cl_41_outer_local_vars {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  int d = 4;

  void test();
}

class O {

  int a = 1, b = 2, c = 3;

  void test() {
    final int b = 20, c = 30;

    I1 i1 = new I1() {

      int c = 300;

      public void test() {
        System.out.println("anon: a = "+ a + ", b = " + b + ", c = " + c + ", d = " + d);
      }
    };

    i1.test();
  }
}
