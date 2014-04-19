/*
Local class LA accessing a field of the enclosing class, that will be shadowed by a local var of the
  enclosing class after the body of LA.
*/

public class local_cl_44_encl_vars_shad_after {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  int a = 100;

  Object createLB() {

    final int b = 20;

    class LB {
      public String toString() {return "O.meth().LB: a="+a + " ,b="+b+", O.this.a="+O.this.a;}
    }

    int a = 1;

    return new LB();
  }
}
