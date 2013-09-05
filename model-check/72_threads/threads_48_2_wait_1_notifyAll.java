/*
Wait-notifyAll, test that all threads are awakened.
  Main thread in sync block: instantiate thread 2, wait, instantiate thread 3, wait.
  Thread 2 in sync block: notify, wait.
  Thread 3 in sync block: notifyAll.
  Messages: around each wait, notify, notifyAll.
  Should render 2 solutions:
    - thread 1 awakens in the end, then thread 2.
    - thread 2 awakens in the end, then thread 1.
*/

public class threads_48_2_wait_1_notifyAll {

  public static void main(String[] args) {
    Object monitor = MyRunnable2.monitor;
    synchronized(monitor) {
      try {
        System.out.println("Thread 1: starting thread 2");
        Thread thread2 = new Thread(new MyRunnable2());
        thread2.start();
        System.out.println("Thread 1: waiting after thread 2");
        monitor.wait();

        System.out.println("Thread 1: awakened, starting thread 3");
        Thread thread3 = new Thread(new MyRunnable3());
        thread3.start();
        System.out.println("Thread 1: waiting after thread 3");
        monitor.wait();
        System.out.println("Thread 1: awakened in the end. Done.");
      } catch (InterruptedException e) {
        System.out.println(e);
      }
    }
  }
}

class MyRunnable2 implements Runnable {

  static Object monitor = new Object();

  public void run() {
    synchronized(monitor) {
      try {
        System.out.println("Thread 2: notifying");
        monitor.notify();
        System.out.println("Thread 2: notified, waiting");
        monitor.wait();
        System.out.println("Thread 2: awakened");
      } catch (InterruptedException e) {
        System.out.println(e);
      }
    }
  }
}

class MyRunnable3 implements Runnable {

  public void run() {
    Object monitor = MyRunnable2.monitor;

    synchronized(monitor) {
      System.out.println("Thread 3: notifying all");
      monitor.notifyAll();
      System.out.println("Thread 3: notified");
    }
  }
}
