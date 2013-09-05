/*
  Main thread: In synchronized block instantiate thread 2 and wait.
  Thread 2: In synchronized block notify.
  Messages: Before wait, after wait, before notify, after notify.
*/

public class threads_46_wait_notify_simp {

  public static void main(String[] args) {
    synchronized(MyRunnable.monitor) {
      Thread thread2 = new Thread(new MyRunnable());
      System.out.println("Thread 1: Starting thread 2");
      thread2.start();

      try {
        System.out.println("Thread 1: waiting");
        MyRunnable.monitor.wait();
        System.out.println("Thread 1: awakened");
      } catch (InterruptedException e) {
        System.out.println(e);
      }
    }
    System.out.println("Done!");
  }
}

class MyRunnable implements Runnable {

  static Object monitor = new Object();

  public void run() {
    synchronized(monitor) {
      System.out.println("Thread 2 notifying");
      monitor.notify();
      System.out.println("Thread 2 notified");
    }
  }
}
