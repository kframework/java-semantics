/*
Local class accessing a local var that shadows a field of the enclosing class.
*/

public class local_cl_43_encl_vars_shadow {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  int a = 100;

  Object createLB() {

    final int a = 1, b = 20;

    class LB {
      public String toString() {return "O.meth().LB: a="+a + " ,b="+b+", O.this.a="+O.this.a;}
    }

    return new LB();
  }
}
