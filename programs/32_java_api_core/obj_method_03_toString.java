//object.toString() where object is: string, userClass with toString overwritten

public class obj_method_03_toString {
  public static void main(String[] args) {
    Object o = "abc";

    //this one will be supported automatically if we'll use String classes
    //System.out.println(o.toString());

    o = new RuntimeException((String)null);
    System.out.println(o.toString());
    System.out.println("Done!");
  }
}
