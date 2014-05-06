class ThreadGame {
  public static void main(String[] args) {
    (new Process()).start() ;
    (new Process()).start() ;
  }
}
class Process extends Thread {
  static int c =1;
  public void run() {
    while (true) {
      c=c+c;
    }
  }
}
