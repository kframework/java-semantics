// != false: object w object, string object w string, array object w array, exception object w exception, userClass w null.

class UserClass {
}

public class ref_op_08_neq_false {
  public static void main(String[] args) {
    Object o, o2;
    o = o2 = new Object();
    System.out.println(o != o2);

    String s2;
    o = s2 = "abc";
    System.out.println(o != s2);

    int[] v2;
    o = v2 = new int[2];
    System.out.println(o != v2);

    UserClass u2;
    o = u2 = new UserClass();
    System.out.println(o != u2);
    System.out.println(u2 != o);

    u2 = null;
    System.out.println(u2 != null);

    System.out.println("Done!");
  }
}
