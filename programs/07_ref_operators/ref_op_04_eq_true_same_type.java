// ==true: object, string, array, exception

class UserClass {
}

public class ref_op_04_eq_true_same_type {
  public static void main(String[] args) {
    Object o1, o2;
    o1 = o2 = new Object();
    System.out.println(o1 == o2);

    String s1, s2;
    s1 = s2 = "abc";
    System.out.println(s1 == s2);

    int[] v1, v2;
    v1 = v2 = new int[2];
    System.out.println(v1 == v2);

    UserClass u1, u2;
    u1 = u2 = new UserClass();
    System.out.println(u1 == u2);

    System.out.println("Done!");
  }
}
