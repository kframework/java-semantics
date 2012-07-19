//object.getClass() where object is: string, array, userClass

public class obj_method_02_getClass {
  public static void main(String[] args) {
    Object o = "abc";

    //this one will be supported automatically if we'll use String and array classes
    //System.out.println(o.getClass().getName());
    //o = new int[3];
    //System.out.println(o.getClass().getName());

    o = new RuntimeException((String)null);
    System.out.println(o.getClass().getName());
    System.out.println("Done!");
  }
}
