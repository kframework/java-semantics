/*
notify is not notifyAll. Same as 42, but use two threads waiting.
  Notifying threads call notify().
*/

public class threads_43_2t_waiting_notify {

  public static void main(String[] args) {
    Thread thread2 = new Thread(new NotifyRunnable(2));
    thread2.start();
    Thread thread3 = new Thread(new NotifyRunnable(3));
    thread3.start();
    Thread waitThread4 = new Thread(new WaitRunnable(4));
    waitThread4.start();
    Thread waitThread5 = new Thread(new WaitRunnable(5));
    waitThread5.start();
    try {
      thread2.join();
      thread3.join();
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
        while (NotifyRunnable.v[2] == 0 || NotifyRunnable.v[3] == 0) {
          System.out.println("WaitRunnable" + id + " v[2] = " + NotifyRunnable.v[2] + ", v[3] = " + NotifyRunnable.v[3]);
          NotifyRunnable.monitor.wait();
        }
        System.out.println("WaitRunnable" + id + " v[2] = " + NotifyRunnable.v[2] + ", v[3] = " + NotifyRunnable.v[3]);
      }
    } catch (InterruptedException e) {
      System.out.println(e);
    }
  }
}
