/*
Two threads assign different value to a static field and print it.
  How many states?
  - th1 - v1, th2 - v1
  - th1 - v1, th2 - v2
  - th1 - v2, th2 - v2
  - other 3 states for th2 followed by th1.
*/

public class threads_14_assign_and_print {

  public static void main(String[] args) {
    new Thread(new MyRunnable()).start();
    A.v = 1;
    System.out.println("Thread1 v = " + A.v);
  }
}

class A {
  static int v;
}

class MyRunnable implements Runnable {
  public void run() {
    A.v = 2;
    System.out.println("Thread2 v = " + A.v);
  }
}
