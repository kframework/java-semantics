/*
  Same as queue_1, but methods get() and put() have the call to wait() wrapped inside if instead of while.
    Still works correctly for 2 threads.

  8 solutions expected.

LTL verification.

In every state where "this" is of type BlockingQueue we have head <= tail:

  kjkompile.sh --threading-sync
  kjrun.sh --ltlmc="[]Ltl (this instanceof BlockingQueue ->Ltl this.head <= this.tail)" \
    ../model-check/73_examples/queue_2_threads_2_wrong.java

Result: true, 50s win, 16s linux. Although this is not the correct producer-consumer algorithm,
  it works correctly in the scenario with just one producer thread and one consumer thread.
*/
public class queue_2_threads_2_wrong {
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
      if (tail-head == capacity) {
        wait();
      }
      array[tail++ % capacity]=element;
      System.out.print("put-" + element + " ");
      notify();
    }
    synchronized int get() throws InterruptedException {
      if (tail-head == 0) {
        wait();
      }
      int element = array[head++ % capacity];
      System.out.print("get-" + element + " ");
      notify();
      return element;
    }
  }
}
