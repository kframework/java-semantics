/*
Two threads assign different value to a static field and print it.
  The pair of statements assignment and printing is a synchronized static method in both threads.
  We shall have just 2 cases: thread 1 first, and thread 2 first.
*/

public class threads_393_sync_st_meth_simpl {

  public static void main(String[] args) {
    MyRunnable.test();
  }
}

class A {
  static int v;
}

class MyRunnable implements Runnable {

  static void test() {
    new Thread(new MyRunnable()).start();
    syncMethod1();
  }

  public void run() {
    syncMethod2();
  }

  synchronized static void syncMethod1() {
      A.v = 1;
      System.out.println("Thread1 v = " + A.v);
  }

  synchronized static void syncMethod2() {
      A.v = 2;
      System.out.println("Thread2 v = " + A.v);
  }
}
