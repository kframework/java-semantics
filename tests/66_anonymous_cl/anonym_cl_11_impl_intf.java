/*
An anonymous class implementing an interface with method test(). Also have an own method and field,
  accessed by test().
*/

public class anonym_cl_11_impl_intf {
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
        System.out.println("anon: v = "+ v + ", f() = " + f());
      }
    };

    i1.test();
  }
}
