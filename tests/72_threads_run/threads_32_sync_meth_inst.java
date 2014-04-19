/*
Writing and printing a value in a synchronized block.
  - thread 1: read val, assign 1, print val, all in a synchronized block.
  - thread 1: read val, assign 1, print val, all in a synchronized block.
  Synchronization is done in an instance synchronized method.
  We shall see just two outputs: thread 1 first and thread 2 first.
*/

public class threads_32_sync_meth_inst {

  public static void main(String[] args) {
    final Test test = new Test();
    Thread thread2 = new Thread(new Runnable() {
      public void run() {
        test.sync(1);
      }
    });
    thread2.start();
    try {
      thread2.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

class Test {

  static int v;

  public synchronized void sync(int id) {
    System.out.println("Thread " + id + " before: v = " + v);
    v = id;
    System.out.println("Thread " + id + " after:  v = " + v);
  }
}
