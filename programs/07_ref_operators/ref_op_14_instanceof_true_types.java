// instanceof true: obj right value instanceof object, string, array, userClass
class UserClass{}

public class ref_op_14_instanceof_true_types {
  public static void main(String[] args) {
    Object o2;

    o2 = new Object();
    System.out.println(o2 instanceof Object);

    o2 = "abc";
    System.out.println(o2 instanceof String);

    o2 = new int[2];
    System.out.println(o2 instanceof int[]);

    o2 = new UserClass();
    System.out.println(o2 instanceof UserClass);

    System.out.println("Done!");
  }
}
