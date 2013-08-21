/*
Two threads, assigning different values to a var. Ech thread does the following:
  - if val == 0, assign value and wait. Then, in any case, notify.
*/

public class threads_41_wait_notify {

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
        if (a == 0) {
          a = id;
          System.out.println("Thread" + id + " waiting...");
          monitor.wait();
        }
        System.out.println("Thread" + id + " a = " + a );
        monitor.notify();
      }
    } catch (InterruptedException e) {
      System.out.println(e);
    }
  }
}
