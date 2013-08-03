/*
Own fields should have higher priority than enclosing locals.
  Local class accessing its own field, that shadows a local var of the enclosing block.
*/

public class local_cl_901_own_fiel_vs_encl_prior {
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

      public String toString() {return "O.createLB().LB: a="+a + " ,b="+b+", this.a="+this.a;}
    }

    System.out.println("O.createLB(): a="+a + " ,b="+b);

    return new LB();
  }
}
