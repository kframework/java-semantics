//object.getClass(), String.getClass(), array.getClass(), userClass.getClass()

public class obj_method_01_getClass {
  public static void main(String[] args) {
    System.out.println(new Object().getClass().getName());

    //this one will be supported automatically if we'll use String and array classes
    //System.out.println("abc".getClass().getName());
    //System.out.println(new int[3].getClass().getName());

    System.out.println(new RuntimeException((String)null).getClass().getName());
    System.out.println("Done!");
  }
}
