/*
Anonymous class accessing fields and methods of the enclosing class by simple name.
*/

public class anonym_cl_12_outer_members {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  void test();
}

class O {

  int v = 1;

  String f() {
    return "anon.f()";
  }

  void test() {
    I1 i1 = new I1() {
      public void test() {
        System.out.println("anon: v = "+ v + ", f() = " + f());
      }
    };

    i1.test();
  }
}
