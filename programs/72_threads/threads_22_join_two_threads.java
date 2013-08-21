/*
3 threads:
  - thread 1: assign to a var val 1, print the val.
  - thread 2: assign to a var val 2, print the val.
  - thread 3: join first two threads in order, then print val.
  We shall observe 8 states.
*/

public class threads_22_join_two_threads {

  public static void main(String[] args) {
    Thread thread2 = new MyThread(2);
    thread2.start();
    Thread thread3 = new MyThread(3);
    thread3.start();
    try {
      thread2.join();
      thread3.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Thread1 v = " + A.v);
  }
}

class A {
  static int v;
}

class MyThread extends Thread {

  int id;

  MyThread(int id) {
      this.id = id;
  }

  public void run() {
    A.v = id;
    System.out.println("Thread" + id + " v = " + A.v);
  }
}
