/*
ArrayStoreException on interplay of Object[] and int[][].
    Object[] vo = new int[][].
    - assign to vo[0]: array of all primitive types, String[], Object[], int[][].
*/

public class array_sep_29_ASException_obj_array {
  public static void main(String[] args) {
    Object[] vo = new int[1][];

    try {
      vo[0] = new int[2];
      System.out.println("ok: int[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new Object[2];
      System.out.println("ok: Object[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new int[2][];
      System.out.println("ok: int[][]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }

    System.out.println("Done!");
  }
}
