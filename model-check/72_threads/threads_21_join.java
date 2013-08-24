/*
Simple join.
  - thread 1: print a message to the console.
  - thread 2: join thread 1, then print a message. We shall see one output.
*/

public class threads_21_join {

  public static void main(String[] args) {
    Thread thread2 = new MyThread();
    thread2.start();
    try {
      thread2.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.println("Thread1");
  }
}

class MyThread extends Thread {
  public void run() {
    System.out.println("Thread2");
  }
}
