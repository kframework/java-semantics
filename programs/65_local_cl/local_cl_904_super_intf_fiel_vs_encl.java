/*
Base interface fields should have higher priority than enclosing locals.
*/

public class local_cl_904_super_intf_fiel_vs_encl {
  public static void main(String[] args) {
    System.out.println(new O().createLB());
    System.out.println("Done!");
  }
}

interface I1 {
  static int a = 60000;
}

class O {

  Object createLB() {

    final int a = 1, b = 20;

    class LB implements I1 {
      public String toString() {return "O.createLB().LB: a="+a + " ,b="+b+", this.a="+this.a;}
    }

    System.out.println("O.createLB(): a="+a + " ,b="+b);

    return new LB();
  }
}
