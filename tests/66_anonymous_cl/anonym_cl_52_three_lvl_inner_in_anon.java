/*
Inner class of an anonymous class. Anonymous implements I1, its inner implements I2.
  Return I2 implementation outside anonymous. From inner access local vars and fields
  of inner, anonymous, method enclosing anonymous, and the top level class.
  Each var hides a bunch of same-named vars from upper levels.
*/

public class anonym_cl_52_three_lvl_inner_in_anon {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  I2 getI2();
}

interface I2 {
  void test();
}

class O {

  int a = 1, b = 2, c = 3, d = 4;

  void test() {
    final int b = 20, c = 30, d = 40;

    I1 i1 = new I1() {

      int c = 300, d= 400;

      class DeepInner implements I2 {
          int d = 4000;

          public void test() {
            System.out.println("deep anon: a = "+ a + ", b = " + b + ", c = " + c + ", d = " + d);
          }
      }

      public I2 getI2() {
        return new DeepInner();
      }
    };

    i1.getI2().test();
  }
}
