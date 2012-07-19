// obj = (?) string : userClass => string
// obj = (?) string : userClass => userClass

class UserClass {
  public String toString() {
    return "user clazz";
  }
}

public class ref_op_19_conditional {
  public static void main(String[] args) {
    System.out.println((1 < 2) ? "abc" : new UserClass());
    System.out.println((1 > 2) ? "abc" : new UserClass());

    System.out.println("Done!");
  }
}
