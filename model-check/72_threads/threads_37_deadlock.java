/*
Deadlock. Two threads, two locks on different objects in different order.
  Thread 1 locks on 2 then 1, thread 2 locks on 1 then 2. In lock 1 assign to var a, in lock 2 assign to b.
  Print a and b inside inner lock, and after inner lock.
  See multiple states and some deadlocks.
  Possible messages:
  22 22 33 33
  22 23 33 33
  33 33 22 22
  33 23 22 22
  deadlock
*/

public class threads_37_deadlock {

  public static void main(String[] args) {
    Thread thread2 = new Thread(new MyRunnable2(2));
    thread2.start();
    Thread thread3 = new Thread(new MyRunnable3(3));
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

class MyRunnable2 implements Runnable {

  static int a;
  static int b;
  static Object monitor1 = new Object();
  static Object monitor2 = new Object();
  int id;

  MyRunnable2(int id) {
      this.id = id;
  }

  public void run() {
    synchronized(monitor1) {
      a = id;
      synchronized(monitor2) {
        b = id;
        System.out.println("Thread" + id + " inner lock: a = " + a + ", b = " + b);
      }
      System.out.println("Thread" + id + " outer lock: a = " + a + ", b = " + b);
    }
  }
}

class MyRunnable3 implements Runnable {

  int id;

  MyRunnable3(int id) {
      this.id = id;
  }

  public void run() {
    synchronized(MyRunnable2.monitor2) {
      MyRunnable2.b = id;
      synchronized(MyRunnable2.monitor1) {
        MyRunnable2.a = id;
        System.out.println("Thread" + id + " inner lock: a = " + MyRunnable2.a + ", b = " + MyRunnable2.b);
      }
      System.out.println("Thread" + id + " outer lock: a = " + MyRunnable2.a + ", b = " + MyRunnable2.b);
    }
  }
}
