/*
Two threads print a message to the console. Check that we have two states at the output.
  Implement Runnable.
*/

public class threads_12_two_th_msg_runnable {

  public static void main(String[] args) {
    new Thread(new MyRunnable()).start();
    System.out.println("Thread1");
  }
}

class MyRunnable implements Runnable {
  public void run() {
    System.out.println("Thread2");
  }
}
