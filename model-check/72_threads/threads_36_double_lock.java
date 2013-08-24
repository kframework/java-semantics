/*
Two threads, two locks on different objects in the same order.
  Thread 1 locks on 1 then 2, thread 2 locks on 1 then 2. In lock 1 assign to var a, in lock 2 assign to b.
  Print a and b inside inner lock, and after inner lock.
  See only 2 states.
*/

public class threads_36_double_lock {

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
  static int b;
  static Object monitor1 = new Object();
  static Object monitor2 = new Object();
  int id;

  MyRunnable(int id) {
      this.id = id;
  }

  public void run() {
    synchronized(monitor1) {
      a = id;
      synchronized(monitor2) {
        b = id;
        System.out.println("Thread" + id + " inner lock: a = " + a + ", b = " + b);
      }
      System.out.println("Thread" + id + " outer lock: a = " + a + ", b = " + b);
    }
  }
}
