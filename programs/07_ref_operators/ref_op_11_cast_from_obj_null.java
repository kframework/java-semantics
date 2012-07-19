// cast from object with value null to: object, string, array, userClass.

class UserClass {
}

public class ref_op_11_cast_from_obj_null {
  public static void main(String[] args) {
    Object o = null;
    Object o2 = (Object) o;
    System.out.println(o == o2);

    String s2 = (String) o;
    System.out.println(o == s2);

    int[] v2 = (int[]) o;
    System.out.println(o == v2);

    UserClass u2 = (UserClass) o;
    System.out.println(o == u2);

    System.out.println("Done!");
  }
}
