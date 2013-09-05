/*
Interrupting a thread locked in join().
  thread 1: start thread 2, join - print , catch interrupted exception - print.
  thread 2: print, interrupt thread 1, print.
  OOMError.
*/

public class threads_52_interrupt_join {

  public static void main(String[] args) {
    WaitingRunnable.thread = new Thread(new WaitingRunnable());
    WaitingRunnable.thread.start();
  }
}

class WaitingRunnable implements Runnable {

  static Thread thread;

  public void run() {
    Thread thread3 = new Thread(new InterruptingRunnable());
    thread3.start();
    try {
      thread3.join();
      System.out.println("Thread 1: awakened successfully");
    } catch (InterruptedException e) {
      System.out.println("Thread 1: " + e);
    }
    System.out.println("Done!");
  }
}

class InterruptingRunnable implements Runnable {

  public void run() {
    System.out.println("Thread 2: interrupting main thread");
    WaitingRunnable.thread.interrupt();
    System.out.println("Thread 2: interrupted main thread");
  }
}
