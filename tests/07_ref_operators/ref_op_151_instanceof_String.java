/*
151. instanceof String:
  String instanceof Object, String, array, userClass.
*/

class UserClass{}

public class ref_op_151_instanceof_String {
  public static void main(String[] args) {
    Object o = "abc";
    System.out.println(o instanceof Object);
    System.out.println(o instanceof String);
    System.out.println(o instanceof int[]);
    System.out.println(o instanceof UserClass);

    System.out.println("Done!");
  }
}
