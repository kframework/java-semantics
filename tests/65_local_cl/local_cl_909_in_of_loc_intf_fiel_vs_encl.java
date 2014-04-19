/*
Inner of local: Interface fields inherited by Local should have higher priority than enclosing local vars.
*/

public class local_cl_909_in_of_loc_intf_fiel_vs_encl {
  public static void main(String[] args) {
    System.out.println(new O().test());
    System.out.println("Done!");
  }
}

interface I1 {
  static int a = 2, b = 20;
}

class O {

  Object test() {

    final int a = 1, b = 10, c = 100;

    class Local implements I1 {

      class InnerOfLocal {
        int a = 3;

        public String toString() {return "O.test().Local.InnerOfLocal: a="+a + " ,b="+b+", c="+c;}
      }
    }

    System.out.println("O.test(): a="+a + " ,b="+b + " ,c="+c);

    return new Local().new InnerOfLocal();
  }
}
