/*
  A blocking queue with capacity 2. One producer thread puts 4 elements into queue, two consumer threads
    takes 2 elements from the queue each. Search should produce all the permitted interleavings, with no deadlocks.
    Since we don't display the thread id, search should produce the same solutions as queue_1.

  8 solutions expected (0 = put, 1 = get):
  00101011
  00101101
  00110011
  00110101
  01001011
  01001101
  01010011
  01010101

  Execution time: 50s on windows.
*/
public class queue_1_threads_2_correct {
  public static void main(String[] args) throws Exception {
    final BlockingQueue queue = new BlockingQueue();
    new Thread() {
      public void run() {
        for(int i=0; i<4; i++) {
          try {
            queue.get();
          } catch(InterruptedException e) {
            System.out.println("Interrupted.");
            return;
          }
        }
      }
    }.start();
    for(int i=0; i<4; i++) {
      queue.put(i);
    }
  }

  static class BlockingQueue {
    int capacity = 2;
    int[] array = new int[capacity];
    int head=0, tail=0;
    synchronized void put(int element) throws InterruptedException {
      while (tail-head == capacity) {
        wait();
      }
      array[tail++ % capacity]=element;
      System.out.print("put-" + element + " ");
      notify();
    }
    synchronized int get() throws InterruptedException {
      while (tail-head == 0) {
        wait();
      }
      int element = array[head++ % capacity];
      System.out.print("get-" + element + " ");
      notify();
      return element;
    }
  }
}
