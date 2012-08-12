//object.getClass(), RuntimeException.getClass(), String.getClass()

public class className_01 {
  public static void main(String[] args) {
    System.out.println(new Object().getClass().getName());
    System.out.println(new RuntimeException((String)null).getClass().getName());
    System.out.println("abc".getClass().getName());

    System.out.println("Done!");
  }
}
