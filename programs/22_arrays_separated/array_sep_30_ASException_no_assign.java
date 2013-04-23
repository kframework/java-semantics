/*
Assignment don't happen when ArrayStoreException is thrown.
*/

public class array_sep_30_ASException_no_assign {
  public static void main(String[] args) {
    Object[] vo = new RuntimeException[1];
    vo[0] = null;
    System.out.println("before exception: " + vo[0]);
    try {
      vo[0] = new Object();
      System.out.println("ok: " + vo[0]);
    } catch (ArrayStoreException e) {
      System.out.println(e);
      System.out.println("after exception: " + vo[0]);
    }
    System.out.println("Done!");
  }
}
