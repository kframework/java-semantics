/*
Two threads, two locks on different objects, but not nested. No deadlocks.
  Thread 1: lock 1, assign and print a, lock 2 - assign and print b.
  Thread 2: lock 2, assign and print b, lock 1 - assign and print a.
  See multiple states, but no deadlocks.
*/

public class threads_38_two_locks {

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
      System.out.println("Thread" + id + " outer lock: a = " + a + ", b = " + b);
    }

    synchronized(monitor2) {
      b = id;
      System.out.println("Thread" + id + " inner lock: a = " + a + ", b = " + b);
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
      System.out.println("Thread" + id + " outer lock: a = " + MyRunnable2.a + ", b = " + MyRunnable2.b);
    }

    synchronized(MyRunnable2.monitor1) {
      MyRunnable2.a = id;
      System.out.println("Thread" + id + " inner lock: a = " + MyRunnable2.a + ", b = " + MyRunnable2.b);
    }
  }
}
