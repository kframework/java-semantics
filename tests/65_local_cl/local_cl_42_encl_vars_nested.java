/*
Local class accessing local vars of the enclosing class defined in nested blocks.
*/

public class local_cl_42_encl_vars_nested {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

class O {

  Object createLB() {

    Object res;

    final int a = 1;
    {
      final int b = 20;

      class LB {
        public String toString() {return "O.meth().LB: a="+a + " ,b="+b;}
      }
      res = new LB();
    }

    return res;
  }
}
