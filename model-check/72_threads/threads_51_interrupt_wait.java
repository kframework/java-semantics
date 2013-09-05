/*
Interrupting a waiting thread.
  thread 1: synchronize, start thread 2, wait, catch InterruptedException.
  thread 2: synchronize, interrupt the second thread.
  One single solution.
*/

public class threads_51_interrupt_wait {

  public static void main(String[] args) {
    WaitingRunnable.thread = new Thread(new WaitingRunnable());
    WaitingRunnable.thread.start();
  }
}

class WaitingRunnable implements Runnable {

  static Thread thread;

  public void run() {
    synchronized(InterruptingRunnable.monitor) {
      Thread thread3 = new Thread(new InterruptingRunnable());
      thread3.start();
      try {
        System.out.println("Thread 1: waiting");
        InterruptingRunnable.monitor.wait();
        System.out.println("Thread 1: awakened successfully");
      } catch (InterruptedException e) {
        System.out.println("Thread 1: " + e);
      }
    }
    System.out.println("Done!");
  }
}

class InterruptingRunnable implements Runnable {

  static Object monitor = new Object();

  public void run() {
    synchronized(monitor) {
      System.out.println("Thread 2: interrupting main thread");
      WaitingRunnable.thread.interrupt();
      System.out.println("Thread 2: interrupted main thread");
    }
  }
}
