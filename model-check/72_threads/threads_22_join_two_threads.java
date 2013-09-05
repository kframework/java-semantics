/*
3 threads:
  - thread 1: assign to a var val 1, print the val.
  - thread 2: assign to a var val 2, print the val.
  - thread 3: join first two threads in order, then print val.
  We shall observe just 2 states with the simplified test.
*/

public class threads_22_join_two_threads {

  public static void main(String[] args) {
    //Instantiating and starting threads in this order is the only chance to make this test to work.
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
    //commented some parts to simplify model checking
    //A.v = id;
    System.out.println("Thread" + id /* + " v = " + A.v*/ );
  }
}
