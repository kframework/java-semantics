/*
Two threads print a message to the console. Check that we have two states at the output.
  Extend the class Thread.
*/

public class threads_11_two_th_msg {

  public static void main(String[] args) {
    new MyThread().start();
    System.out.println("Thread1");
  }
}

class MyThread extends Thread {
  public void run() {
    System.out.println("Thread2");
  }
}
