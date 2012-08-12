//object.getClass() where object is: RuntimeException, String

public class className_02 {
  public static void main(String[] args) {
    Object o;

    o = new RuntimeException((String)null);
    System.out.println(o.getClass().getName());

    o = "abc";
    System.out.println(o.getClass().getName());

    System.out.println("Done!");
  }
}
