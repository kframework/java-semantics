/*
Anonymous class inside another anonymous. MidAnon implements I1, DeepAnon implements I2.
  Return I2 implementation outside MidAnon. From DeepAnon access local vars and fields
  of DeepAnon, method enclosing DeepAnon, MidAnon, method enclosing MidAnon, and the top level class.
  Each var hides a bunch of same-named vars from upper levels.
*/

public class anonym_cl_51_three_lvl_anon_in_anon {
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

  int a = 1, b = 2, c = 3, d = 4, e = 5;

  void test() {
    final int b = 20, c = 30, d = 40, e = 50;

    I1 i1 = new I1() {

      int c = 300, d= 400, e = 500;

      public I2 getI2() {
        final int d = 4000, e = 5000;

        I2 i2 = new I2() {
          int e = 50000;

          public void test() {
            System.out.println("deep anon: a = "+ a + ", b = " + b + ", c = " + c + ", d = " + d + ", e = " + e);
          }
        };

        return i2;
      }
    };

    i1.getI2().test();
  }
}
