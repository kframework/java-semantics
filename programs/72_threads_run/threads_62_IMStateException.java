/*
Attempt to wait, notify, notifyAll on a thread with no lock acquired.
  Catch IllegalMonitorStateException.
*/

public class threads_62_IMStateException {

  public static void main(String[] args) {
    Object monitor = new Object();
    try {
      System.out.println("wait():");
      monitor.wait();
      System.out.println("unreachable");
    } catch (Exception e) {
      System.out.println(e);
    }
    try {
      System.out.println("notify():");
      monitor.notify();
      System.out.println("unreachable");
    } catch (Exception e) {
      System.out.println(e);
    }
    try {
      System.out.println("notifyAll():");
      monitor.notifyAll();
      System.out.println("unreachable");
    } catch (Exception e) {
      System.out.println(e);
    }

    System.out.println("Done!");
  }
}
