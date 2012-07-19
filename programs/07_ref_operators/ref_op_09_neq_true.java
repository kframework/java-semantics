// != true, object w object, object w obj string, object w obj array, object w obj userClass, obj userClass w obj null.

class UserClass {
}

public class ref_op_09_neq_true {
  public static void main(String[] args) {
    Object o = new Object();
    Object o2 = new Object();
    System.out.println(o != o2);

    String s2;
    s2 = "abc";
    System.out.println(o != s2);

    int[] v2;
    v2 = new int[2];
    System.out.println(o != v2);

    UserClass u2;
    u2 = new UserClass();
    System.out.println(o != u2);
    System.out.println(u2 != o);

    o = null;
    System.out.println(o != u2);

    System.out.println("Done!");
  }
}
