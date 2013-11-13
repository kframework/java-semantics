/*
One thread waiting, two threads notifying.
  Thread 1: assign a, notify.
  Thread 2: assign b, notify.
  Thread 3: while a == 0 or b == 0, print a, b, wait.

  Thread interleaving:
  1 2 3
  1 3 2 3
  3 1 3 2 3
  3 1 2 3
  2 1 3
  2 3 1 3
  3 2 3 1 3
  3 2 1 3

  8 cases.
*/

public class threads_42_1t_wait_2t_notify {

  public static void main(String[] args) {
    Thread thread2 = new Thread(new NotifyRunnable(2));
    thread2.start();
    Thread thread3 = new Thread(new NotifyRunnable(3));
    thread3.start();
    Thread waitThread = new Thread(new WaitRunnable());
    waitThread.start();
    try {
      thread2.join();
      thread3.join();
      waitThread.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

class NotifyRunnable implements Runnable {

  static int[] v = new int[4];
  static Object monitor = new Object();
  int id;

  NotifyRunnable(int id) {
      this.id = id;
  }

  public void run() {
    synchronized(monitor) {
      v[id] = id;
      System.out.println("Thread" + id + " notifying...");
      monitor.notify();
    }
  }
}

class WaitRunnable implements Runnable {

  public void run() {
    try {
      synchronized(NotifyRunnable.monitor) {
        while (NotifyRunnable.v[2] == 0 || NotifyRunnable.v[3] == 0) {
          System.out.println("WaitRunnable" + " v[2] = " + NotifyRunnable.v[2] + ", v[3] = " + NotifyRunnable.v[3]);
          NotifyRunnable.monitor.wait();
        }
        System.out.println("WaitRunnable" + " v[2] = " + NotifyRunnable.v[2] + ", v[3] = " + NotifyRunnable.v[3]);
      }
    } catch (InterruptedException e) {
      System.out.println(e);
    }
  }
}
