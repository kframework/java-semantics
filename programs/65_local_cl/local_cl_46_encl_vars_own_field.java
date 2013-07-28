/*
Local class accessing its own field, that shadows a local var of the enclosing block.
*/

public class local_cl_46_encl_vars_own_field {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  Object createLB() {

    final int a = 1, b = 20;

    class LB {
      int a = 30;

      public String toString() {return "O.meth().LB: a="+a + " ,b="+b+", this.a="+this.a;}
    }

    return new LB();
  }
}
