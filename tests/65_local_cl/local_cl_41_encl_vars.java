/*
Local class accessing local vars of the enclosing class defined in one single block.
*/

public class local_cl_41_encl_vars {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  Object createLB() {

    final int a = 1, b = 20;

    class LB {
      public String toString() {return "O.meth().LB: a="+a + " ,b="+b;}
    }

    return new LB();
  }
}
