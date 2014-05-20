public class WaitNotifyQueue {
  public static void main(String[] args) throws Exception {
    final BlockingQueue queue = new BlockingQueue();
    Thread t2 = new Thread() {
      public void run() {
        for(int i=0; i<3; i++) {
          try {
            queue.get();
          } catch(InterruptedException e) {
            System.out.println("Interrupted.");
            return;
          }
        }
      }
    };
    t2.start();
    for(int i=0; i<3; i++) {
      queue.put(i);
    }
    t2.interrupt();
  }

  static class BlockingQueue {
    int[] array = new int[2];
    int size=0;
    synchronized void put(int element) throws InterruptedException {
      while(size == array.length) {
        wait();
      }
      array[size++]=element;
      System.out.print("put-" + element + " ");
      notify();
    }
    synchronized int get() throws InterruptedException {
      while(size == 0) {
        wait();
      }
      int element = array[--size];
      System.out.print("get-" + element + " ");
      notify();
      return element;
    }
  }
}
