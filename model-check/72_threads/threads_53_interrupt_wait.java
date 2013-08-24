/*
Interrupting a waiting thread.
  thread 1: synchronize, notify, print, then wait print, then catch InterruptedException, print. At the end: print.
  thread 2: synchronize, print - interrupt the second thread, then print - join the second thread,
  then print "Done!".
*/

public class threads_53_interrupt_wait {

  public static void main(String[] args) {
    WaitingRunnable.thisThread = new Thread(new WaitingRunnable());
    WaitingRunnable.thisThread.start();
    Thread thread3 = new Thread(new InterruptingRunnable());
    thread3.start();
    try {
      WaitingRunnable.thisThread.join();
      thread3.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

class WaitingRunnable implements Runnable {

  static Object monitor = new Object();
  static Thread thisThread;
  static boolean started;

  public void run() {
    try {
      synchronized(monitor) {
        started = true;
        monitor.notify();
        System.out.println("WaitingRunnable waiting...");
        monitor.wait();
        System.out.println("unreachable");
      }
    } catch(Exception e) {
      System.out.println("WaitingRunnable: " + e);
    }
  }
}

class InterruptingRunnable implements Runnable {

  public void run() {
    try {
      synchronized(WaitingRunnable.monitor) {
        while(!WaitingRunnable.started) {
          System.out.println("InterruptingRunnable waiting...");
          WaitingRunnable.monitor.wait();
        }
        System.out.println("InterruptingRunnable interrupting...");
        WaitingRunnable.thisThread.interrupt();
      }
      System.out.println("InterruptingRunnable joining...");
      WaitingRunnable.thisThread.join();
    } catch(Exception e) {
      System.out.println("InterruptingRunnable: " + e);
    }
  }
}
