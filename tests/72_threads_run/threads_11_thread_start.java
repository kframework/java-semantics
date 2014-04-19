/*
Two threads print a message to the console. Check that we have two states at the output.
  Extend the class Thread.
*/

public class threads_11_thread_start {

  public static void main(String[] args) {
    new MyThread().start();
  }
}

class MyThread extends Thread {
  public void run() {
    System.out.println("Done!");
  }
}
