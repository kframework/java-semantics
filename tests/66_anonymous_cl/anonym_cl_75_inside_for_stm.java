/*
Anonymous class inside for first clause - initializer, the clause is expression declaration.
*/

public class anonym_cl_75_inside_for_stm {
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
    for(
      I1 i1 = new I1() {

        int v = 1;

        String f() {
          return "anon.f()";
        }

        public void test() {
          System.out.println("anon: v = "+ v + ", f() = " + f());
        }
      };
      i1 != null;
      i1 = null
    ) {
      i1.test();
    }
  }
}
