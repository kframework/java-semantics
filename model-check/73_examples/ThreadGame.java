//With the restrictions below produces 10 solutions: 5,6,7,8,9,10,11,12,14,16
class ThreadGame {
  public static void main(String[] args) {
    Process p1 = new Process();
    Process p2 = new Process();
    p1.start();
    p2.start();
    try {
      p1.join();
      p2.join();
    } catch (InterruptedException e) {
      System.out.println(e);
    }
    System.out.print(Process.c + " ");
  }
}
class Process extends Thread {
  static int c=1;
  public void run() {
    while (c < 5) {
      c=c+c;
    }
  }
}
