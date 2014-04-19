// ==true: string object w string, array object w array, userClass object w userClass, userClass w null

class UserClass {
}

public class ref_op_05_eq_true_diff_type {
  public static void main(String[] args) {
    Object o;

    String s2;
    o = s2 = "abc";
    System.out.println(o == s2);

    int[] v2;
    o = v2 = new int[2];
    System.out.println(o == v2);

    UserClass u2;
    o = u2 = new UserClass();
    System.out.println(o == u2);
    System.out.println(u2 == o);

    u2 = null;
    System.out.println(u2 == null);

    System.out.println("Done!");
  }
}
