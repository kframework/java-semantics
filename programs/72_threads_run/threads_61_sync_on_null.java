/*
Synchronizing on null should throw NullPoitnerException.
*/

public class threads_61_sync_on_null {

  public static void main(String[] args) {
    Object monitor = null;
    try {
      synchronized(monitor) {
        System.out.println("unreachable");
      }
    } catch (RuntimeException e) {
      System.out.println(e);
    }

    System.out.println("Done!");
  }
}
