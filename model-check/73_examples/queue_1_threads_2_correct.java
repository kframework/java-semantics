/*
  A blocking queue with capacity 2. One producer thread puts 4 elements into queue, one consumer thread
    takes 4 elements from the queue. Search should produce all the permitted interleavings, with no deadlocks.
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

  Attempts to execute on a bigger data set:
    - Linux, transition-thrading, n=10, capacity=5 => OOME after 5 hours, 1GB heap.
    - Linux, transition-sync, n=10, capacity=4 => OOME after 2 hours.

LTL verification.

In every state where "this" is of type BlockingQueue we have head <= tail:
  The set of parentheses after []Ltl is necessary,
    otherwise formula will be grouped as ( ([]LTL ...) ->LTL ... ) .

  kjkompile.sh --threading-sync
  kjrun.sh --ltlmc="[]Ltl (this instanceof BlockingQueue ->Ltl this.head <= this.tail)" \
    ../model-check/73_examples/queue_1_threads_2_correct.java

Result: true, 50s win, 16s linux.
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
