/*
Interrupting a thread locked in join().
  thread 1: start thread 2, join - print , catch interrupted exception - print.
  thread 2: print, interrupt thread 1, print.
*/

public class threads_54_interrupt_join {

  public static void main(String[] args) {
    A.mainThread = Thread.currentThread();
    Thread interrupter = new Thread(new InterruptingRunnable());
    interrupter.start();
    try {
      System.out.println("Joining interrupter...");
      interrupter.join();
      System.out.println("rarely reachable");
    } catch (InterruptedException e) {
      System.out.println("Main thread: " + e);
    }
    System.out.println("Done!");
  }
}

class A {
  static Object monitor = new Object();
  static Thread mainThread;
}

class InterruptingRunnable implements Runnable {

  public void run() {
    try {
      synchronized(A.monitor) {
        System.out.println("InterruptingRunnable interrupting main thread...");
        A.mainThread.interrupt();
        System.out.println("InterruptingRunnable interrupted main thread...");
      }
    } catch(Exception e) {
      System.out.println("InterruptingRunnable: " + e);
    }
  }
}
