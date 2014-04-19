/*
Base class fields should have higher priority than enclosing locals.
*/

public class local_cl_902_super_fiel_vs_encl {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class A {
  int a = 400;
}

class O {

  void test() {

    final int a = 1, b = 20;

    class Local extends A {
      public String toString() {return "O.test().Local: a="+a + " ,b="+b+", this.a="+this.a;}
    }

    System.out.println("O.test(): a="+a + " ,b="+b);

    System.out.println(new Local());
  }
}
