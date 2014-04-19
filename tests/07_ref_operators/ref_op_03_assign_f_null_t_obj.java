// assign from null object, string, array, user class to object.

class UserClass {
}

public class ref_op_03_assign_f_null_t_obj {
  public static void main(String[] args) {
    Object out;
    Object o = null;
    System.out.println(out = o);

    String s = null;
    System.out.println(out = s);

    int[] v = null;
    System.out.println(out = v);

    UserClass u = null;
    System.out.println(out = u);

    System.out.println("Done!");
  }
}
