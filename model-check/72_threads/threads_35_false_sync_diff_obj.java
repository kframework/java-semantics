/*
36. When two threads synchronize on different objects, it is as no synchronization
  occurred at all. Same as 31, use synchronized blocks on different newly created instances of Object.
  7 outputs. Message interleaving possibilities:

    T1-0 T1-1 T2-0 T2-2
    T1-0 T1-2 T2-0 T2-2
    T1-0 T1-1 T2-0 T2-1

    T1-0 T1-1 T2-1 T2-2

    T1 T2 T1 T2 1
    T1 T2 T2 T1 1v
    T2 T1 T1 T2 1v
    T2 T1 T2 T1 1v
    T2 T2 T1 T1 1v

    And many other possibilities. Total: 24.
*/

public class threads_35_false_sync_diff_obj {

  public static void main(String[] args) {
    Thread thread2 = new MyThread(2);
    Thread thread3 = new MyThread(3);
    thread2.start();
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

class MyThread extends Thread {

  static int v;
  Object monitor = new Object();
  int id;

  MyThread(int id) {
      this.id = id;
  }

  public void run() {
    synchronized(monitor) {
      sync(id);
    }
  }

  public void sync(int id) {
    System.out.println("Thread" + id + " before: v = " + v);
    v = id;
    System.out.println("Thread" + id + " after:  v = " + v);
  }
}
