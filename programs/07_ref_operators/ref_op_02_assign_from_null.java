// Object = null, String = null, array = null, userClass = null.
// Call to print tests that null of any type is correctly printed.
// Call to println tests that the expression (null + "\n") , null of any type, is correctly executed.

class UserClass {
}

public class ref_op_02_assign_from_null {
  public static void main(String[] args) {
    Object o = null;
    System.out.print(o);
    System.out.println(o);

    String s = null;
    System.out.print(s);
    System.out.println(s);

    int[] v = null;
    System.out.print(v);
    System.out.println(v);

    UserClass u = null;
    System.out.print(u);
    System.out.println(u);

    System.out.println("Done!");
  }
}
