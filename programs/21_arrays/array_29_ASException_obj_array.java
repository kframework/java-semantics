/*
ArrayStoreException on interplay of Object[] and int[][].
    Object[] vo = new int[][].
    - assign to vo[0]: array of all primitive types, String[], Object[], int[][].
*/

public class array_29_ASException_obj_array {
  public static void main(String[] args) {
    Object[] vo = new int[1][];

    try {
      vo[0] = new byte[2];
      System.out.println("ok: byte[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new short[2];
      System.out.println("ok: short[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new int[2];
      System.out.println("ok: int[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new long[2];
      System.out.println("ok: long[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new char[2];
      System.out.println("ok: char[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new boolean[2];
      System.out.println("ok: boolean[]");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      vo[0] = new String[2];
      System.out.println("ok: String[]");
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
