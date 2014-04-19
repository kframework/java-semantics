/*
Writing and printing a value in a synchronized block.
  - thread 1: read val, assign 1, print val, all in a synchronized block.
  - thread 1: read val, assign 1, print val, all in a synchronized block.
  Synchronization is done in a synchronized block with argument an object.
  We shall see just two outputs: thread 1 first and thread 2 first.

  Crashed with OOMError in 17 min with 20GB heap setting.
  Look at the test 391 - tested the same situation, but that one is simple enough
  to be handled by fmse server.
*/

public class threads_34_sync_obj {

  public static void main(String[] args) {
    Thread thread2 = new MyThread(2);
    thread2.start();
    try {
      thread2.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

class MyThread extends Thread {

  static int v;
  static Object monitor = new Object();
  int id;

  MyThread(int id) {
      this.id = id;
  }

  public void run() {
    sync(id);
  }

  public static void sync(int id) {
    synchronized(monitor) {
      System.out.println("Thread" + id + " before: v = " + v);
      v = id;
      System.out.println("Thread" + id + " after:  v = " + v);
    }
  }
}
