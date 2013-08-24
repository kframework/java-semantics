/*
Writing and printing a value in a synchronized block.
  - thread 1: read val, assign 1, print val, all in a synchronized block.
  - thread 1: read val, assign 1, print val, all in a synchronized block.
  Synchronization is done in an instance synchronized method.
  We shall see just two outputs: thread 1 first and thread 2 first.
*/

public class threads_32_sync_meth_inst {

  public static void main(String[] args) {
    Runnable runnable = new MyRunnable();
    Thread thread2 = new Thread(runnable);
    thread2.start();
    Thread thread3 = new Thread(runnable);
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

  static int v;
  int id;

  MyRunnable() {}

  public void run() {
    sync(++id);
  }

  public synchronized void sync(int id) {
    System.out.println("Thread" + id + " before: v = " + v);
    v = id;
    System.out.println("Thread" + id + " after:  v = " + v);
  }
}
