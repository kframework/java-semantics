/*
Own fields should have higher priority than enclosing locals.
  Local class accessing its own field, that shadows a local var of the enclosing block.
*/

public class local_cl_901_own_fiel_vs_encl_prior {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1, b = 20;

    class Local {
      int a = 30;

      public String toString() {return "O.test().Local: a="+a + " ,b="+b+", this.a="+this.a;}
    }

    System.out.println("O.test(): a="+a + " ,b="+b);

    System.out.println(new Local());
  }
}
