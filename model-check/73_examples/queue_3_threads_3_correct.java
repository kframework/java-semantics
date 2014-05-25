/*
  A blocking queue with capacity 2. One producer thread puts 4 elements into queue, two consumer threads
    takes 2 elements from the queue each.
    Distinction from queue_1 is that here we have two consumers that each take 2 elements, 3 threads in total.
    Search should produce all the permitted interleavings, with no deadlocks. The same solutions as for queue_1.

  8 solutions expected (0 = put, 1 = get):
  00101011
  00101101
  00110011
  00110101
  01001011
  01001101
  01010011
  01010101

  Execution time: 4m15s on windows. Same output, but internally there are x times more cases.
  Among consumer threads there are 6 times more cases. The following interleavings are possible among threads 2 and 3:
    2233, 2323, 2332, 3223, 3232, 3322.

LTL verification. In every state where "this" is of type BlockingQueue we have head <= tail:

  kjrun.sh --timeout=0 --ltlmc="[]Ltl (this instanceof BlockingQueue ->Ltl this.head <= this.tail)" \
    ../model-check/73_examples/queue_3_threads_3_correct.java

Result: true, 4m20s win, 1m linux.
*/
public class queue_3_threads_3_correct {
  public static void main(String[] args) throws Exception {
    final BlockingQueue queue = new BlockingQueue();
    for(int tid=0; tid<2; tid++) {
      new Thread() {
        public void run() {
          for (int i=0; i<2; i++) {
            try {
              queue.get();
            } catch (InterruptedException e) {
              System.out.println("Interrupted.");
              return;
            }
          }
        }
      }.start();
    }
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
