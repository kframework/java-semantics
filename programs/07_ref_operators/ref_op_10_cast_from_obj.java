// cast from object to: object, string, array, exception.

class UserClass {
  public String toString() {
    return "user clazz";
  }
}

public class ref_op_10_cast_from_obj {
  public static void main(String[] args) {
    Object o = new Object();
    Object o2 = (Object) o;
    System.out.println(o.getClass().getName());

    o = "abc";
    String s2 = (String) o;
    System.out.println(s2);

    o = new int[2];
    int[] v2 = (int[]) o;
    v2[0] = 12;
    System.out.println(v2[0]);

    o = new UserClass();
    UserClass u2 = (UserClass) o;
    System.out.println(u2);

    System.out.println("Done!");
  }
}
