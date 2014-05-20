/*
Function notify() is not notifyAll(). Same as 42, but use two threads for waiting, one thread for notifying.
  Notifying thread calls notify() twice.

    Thread interleaving:
  2 4 5
  2 5 4
  4 2 4 5
  4 2 5 4
  5 2 4 5
  5 2 5 4
  4 5 2 4 2 5
  4 5 2 5 2 4
  5 4 2 4 2 5
  5 4 2 5 2 4
  4 5 2 2 4 5
  4 5 2 2 5 4
  5 4 2 2 4 5
  5 4 2 2 5 4

  Total: 14 solutions.
*/

public class threads_43_2t_waiting_notify {

  public static void main(String[] args) {
    Thread thread2 = new Thread(new NotifyRunnable(2));
    Thread waitThread4 = new Thread(new WaitRunnable(4));
    Thread waitThread5 = new Thread(new WaitRunnable(5));
    thread2.start();
    waitThread4.start();
    waitThread5.start();
    try {
      thread2.join();
      waitThread4.join();
      waitThread5.join();
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
    synchronized(monitor) {
      monitor.notify();
    }
  }
}

class WaitRunnable implements Runnable {

  int id;

  WaitRunnable(int id) {
      this.id = id;
  }

  public void run() {
    try {
      synchronized(NotifyRunnable.monitor) {
        while (NotifyRunnable.v[2] == 0) {
          System.out.println("WaitRunnable" + id + " v[2] = " + NotifyRunnable.v[2]);
          NotifyRunnable.monitor.wait();
        }
        System.out.println("WaitRunnable" + id + " v[2] = " + NotifyRunnable.v[2]);
      }
    } catch (InterruptedException e) {
      System.out.println(e);
    }
  }
}
