/*
Two threads assign different value to a static field and print it.
  The pair of statements assignment and printing is synchronized in both threads.
  We shall have just 2 cases: thread 1 first, and thread 2 first.
*/

public class threads_391_sync_obj_simplified {

  public static void main(String[] args) {
    new Thread(new MyRunnable()).start();
    synchronized(A.monitor) {
      A.v = 1;
      System.out.println("Thread1 v = " + A.v);
    }
  }
}

class A {
  static int v;
  static Object monitor = new Object();
}

class MyRunnable implements Runnable {
  public void run() {
    synchronized(A.monitor) {
      A.v = 2;
      System.out.println("Thread2 v = " + A.v);
    }
  }
}
