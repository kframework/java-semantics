// == false: object w object, string w string, diff. content, array w array, same content, exception w exception, same content

class UserClass {
}

public class ref_op_06_eq_false_same_type {
  public static void main(String[] args) {
    Object o1, o2;
    o1 = new Object();
    o2 = new Object();
    System.out.println(o1 == o2);

    String s1, s2;
    s1 = "abc";
    s2 = "abcd";
    System.out.println(s1 == s2);

    int[] v1, v2;
    v1 = new int[1];
    v1[0] = 12;
    v2 = new int[1];
    v2[0] = 12;
    System.out.println(v1 == v2);

    v1 = new int[0];
    v2 = new int[0];
    System.out.println(v1 == v2);

    UserClass u1, u2;
    u1 = new UserClass();
    u2 = new UserClass();
    System.out.println(u1 == u2);

    System.out.println("Done!");
  }
}
