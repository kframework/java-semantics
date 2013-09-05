/*
Wait-notify, test that just one thread from 2 are awakened.
  Main thread in sync block: instantiate thread 2, wait, instantiate thread 3, wait.
  Thread 2 in sync block: notify, wait.
  Thread 3: sync block - notify, sync block - notify.
  Messages: around each wait and notify.
  Should render 4 solutions:
    - thread 3 notify, thread 1 awakes, thread 3 notify, thread 2 awakes.
    - thread 3 notify, thread 2 awakes, thread 3 notify, thread 1 awakes.
    - thread 3 notify, thread 3 notify, thread 1 awakes, thread 2 awakes.
    - thread 3 notify, thread 3 notify, thread 2 awakes, thread 1 awakes.
*/

public class threads_47_2_wait_1_notify {

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
      System.out.println("Thread 3: notifying");
      monitor.notify();
      System.out.println("Thread 3: notified");
    }
    synchronized(monitor) {
      System.out.println("Thread 3: notifying again");
      monitor.notify();
      System.out.println("Thread 3: end");
    }
  }
}
