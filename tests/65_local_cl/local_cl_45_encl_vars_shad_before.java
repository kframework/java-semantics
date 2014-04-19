/*
Local class LA accessing a field of the enclosing class, that was shadowed by a local var of the
  enclosing class before the body of LA, but whose scope is over.
*/

public class local_cl_45_encl_vars_shad_before {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  int a = 100;

  Object createLB() {

    final int b = 20;
    {
      final int a = 1;
      System.out.println("a="+a);
    }

    class LB {
      public String toString() {return "O.meth().LB: a="+a + " ,b="+b+", O.this.a="+O.this.a;}
    }

    return new LB();
  }
}
