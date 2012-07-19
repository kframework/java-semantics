// == false, object w obj string, object w obj array, object w obj exception, obj userClass w obj null.

class UserClass {
}

public class ref_op_07_eq_false_diff_type {
  public static void main(String[] args) {
    Object o = new Object();

    String s2;
    s2 = "abc";
    System.out.println(o == s2);

    int[] v2;
    v2 = new int[2];
    System.out.println(o == v2);

    UserClass u2;
    u2 = new UserClass();
    System.out.println(o == u2);
    System.out.println(u2 == o);

    o = null;
    System.out.println(o == u2);

    System.out.println("Done!");
  }
}
