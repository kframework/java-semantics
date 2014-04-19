/*
Inside the same method, two anonymous classes implementing I. I have method test().
  Call the test of both of them, using the same local var, and observe the difference.
*/

public class anonym_cl_61_two_anon_cl {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  void test();
}

class O {

  void test() {
    I1 i1 = new I1() {

      int v = 1;

      String f() {
        return "anon.f()";
      }

      public void test() {
        System.out.println("anon1.test(): v = "+ v + ", f() = " + f());
      }
    };

    i1.test();

    i1 = new I1() {

      public void test() {
        System.out.println("anon2.test()");
      }
    };

    i1.test();
  }
}
