/*
Local class accessing a local var that shadows a field of the enclosing class.
*/

public class local_cl_43_encl_vars_shadow {
  public static void main(String[] args) {
    System.out.println(new O().createLocal());
    System.out.println("Done!");
  }
}

class O {

  int a = 100;

  Object createLocal() {

    final int a = 1, b = 20;

    class Local {
      public String toString() {return "O.createLocal().Local: a="+a + " ,b="+b+", O.this.a="+O.this.a;}
    }

    return new Local();
  }
}
