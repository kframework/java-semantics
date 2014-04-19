// null instanceof object, string, array, userClass.
// null literal instanceof Object

class UserClass{}

public class ref_op_16_instanceof_null_types {
  public static void main(String[] args) {
    Object o = null;

    System.out.println(o instanceof Object);
    System.out.println(o instanceof String);
    System.out.println(o instanceof int[]);
    System.out.println(o instanceof UserClass);
    System.out.println(null instanceof Object);

    System.out.println("Done!");
  }
}
