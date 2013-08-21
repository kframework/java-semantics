/*
Two threads print a message to the console. Extend the class Thread.
  Call the method run() on threads instead of start().
*/

public class threads_13_two_th_false_start {

  public static void main(String[] args) {
    new MyThread().run();
    System.out.println("Thread1");
  }
}

class MyThread extends Thread {
  public void run() {
    System.out.println("Thread2");
  }
}
