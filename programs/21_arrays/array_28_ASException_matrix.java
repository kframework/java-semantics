/*
ArrayStoreException on matrixes.
    Object[][] mo = new RuntimeException[][];
    - mo[0] = new Object[] - ASException
    mo[0] = new NullPointerException[] - ok
    - mo[0][0] = new Object() - ASException
    - mo[0][0] = new RuntimeException() - ASException
    mo[0][0] = new NullPointerException() - ok
*/

public class array_28_ASException_matrix {
  public static void main(String[] args) {
    Object[][] mo = new RuntimeException[1][];
    try {
      mo[0] = new Object[1];
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      mo[0] = new RuntimeException[1];
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      mo[0] = new NullPointerException[1];
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      mo[0][0] = new Object();
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      mo[0][0] = new RuntimeException("abc");
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      mo[0][0] = new NullPointerException("npe");
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}
