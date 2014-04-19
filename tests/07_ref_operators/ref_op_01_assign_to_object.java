// assign to object: object, string, array, user class.

class UserClass {
  public String toString() {
    return "UserClass";
  }
}

public class ref_op_01_assign_to_object {
  public static void main(String[] args) {
    Object o;
    System.out.println((o = new Object()).getClass().getName());
    System.out.println(o = "ab");

    o = new int[1];
    System.out.println(o == o);

    System.out.println(o = new UserClass());
    System.out.println("Done!");
  }
}
