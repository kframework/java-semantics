/*
Test that synchronization status is preserved among method calls.
  Same as 41, but do synchronize() in one method, and wait() in a method called by the first one.
*/

public class threads_45_lock_preserve {

  public static void main(String[] args) {
    Thread thread2 = new Thread(new MyRunnable(2));
    thread2.start();
    Thread thread3 = new Thread(new MyRunnable(3));
    thread3.start();
    try {
      thread2.join();
      thread3.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

class MyRunnable implements Runnable {

  static int a;
  static Object monitor = new Object();
  int id;

  MyRunnable(int id) {
      this.id = id;
  }

  public void run() {
    try {
      synchronized(monitor) {
        innerRun();
      }
    } catch (InterruptedException e) {
      System.out.println(e);
    }
  }

  void innerRun() throws InterruptedException {
    if (a == 0) {
      a = id;
      System.out.println("Thread" + id + " waiting...");
      monitor.wait();
    }
    System.out.println("Thread" + id + " a = " + a );
    monitor.notify();
  }
}
