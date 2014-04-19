/*
Base interface fields should have higher priority than enclosing locals.
*/

public class local_cl_904_super_intf_fiel_vs_encl {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  static int a = 60000;
}

class O {

  void test() {

    final int a = 1, b = 20;

    class Local implements I1 {
      public String toString() {return "O.test().Local: a="+a + " ,b="+b+", this.a="+this.a;}
    }

    System.out.println("O.test(): a="+a + " ,b="+b);

    System.out.println(new Local());
  }
}
