/*
Class declared in a place where "a" have one val, instantiated where "a" have another val,
  but in both places a is a local var. Check the difference.
*/

public class local_cl_911_decl_vs_inst_env_diff {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 10, c = 100;

    class Local1 {
      public String toString() {
        return "O.test().Local: a="+a + " ,b="+b + " ,c="+c;
      }
    }

    class Local2 {
      int a = 2, b = 20;

      void test() {
        int a = 3;

        System.out.println("Instantiating Local1 from Local2:");
        System.out.println(new Local1());
      }
    }

    System.out.println("O.test(): a="+a + " ,b="+b + " ,c="+c+ "\n");

    new Local2().test();
  }
}
