/*
6. Array of references:
  Object[], String[], RuntimeException[]
*/

public class className_06_array_ref {
  public static void main(String[] args) {
    System.out.println(new Object[0].getClass().getName());
    System.out.println(new String[0].getClass().getName());
    System.out.println(new RuntimeException[0].getClass().getName());

    System.out.println("\nDone!");
  }
}
