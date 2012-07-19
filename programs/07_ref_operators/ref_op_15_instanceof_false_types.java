// instanceof false: obj string, obj array, obj userClass1 as object, userClass2
class UserClass1{}
class UserClass2{}

public class ref_op_15_instanceof_false_types {
  public static void main(String[] args) {
    Object o = new Object();
    Object uc1 = new UserClass1();
    o = new Object();

    System.out.println(o instanceof String);
    System.out.println(uc1 instanceof String);
    System.out.println(o instanceof int[]);
    System.out.println(uc1 instanceof int[]);
    System.out.println(o instanceof UserClass2);
    System.out.println(uc1 instanceof UserClass2);

    System.out.println("Done!");
  }
}
