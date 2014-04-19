/*
Inner of local: Ability to accesses vars from enclosing local env of the enclosing Local.
*/

public class local_cl_905_inner_of_local_encl {
  public static void main(String[] args) {
    System.out.println(new O().test());
    System.out.println("Done!");
  }
}

class O {

  Object test() {

    final int a = 1, b = 10, c = 100;

    class Local {

      class InnerOfLocal {

        public String toString() {return "O.test().Local.InnerOfLocal: a="+a + " ,b="+b+", c="+c;}
      }
    }

    return new Local().new InnerOfLocal();
  }
}
