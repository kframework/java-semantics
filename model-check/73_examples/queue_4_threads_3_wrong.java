/*
  One producer, 4 items. 2 consumers, 2 items each.

The correct program (queue_3) have wait() call surrounded by a while statement inside both producer and consumer.
  But if we replace while by if (this program), we might get into an incorrect state
  when a consumer reads the last element in the queue and awakes the other consumer, instead of awakening the producer.
  The other consumer will consume an inexisting element and will increment head over the tail. This case may only
  happen if there are either at least two producers or two consumers. If there is only one producer and one consumer,
  even the wrong program will perform correctly. The invalid state will be represented by head > tail.

LTL formula to be checked: at any moment head <= tail.

The problematic execution path won't lead to any deadlocks, and the final configuration will look good, but the output
  will be different compared to correct execution. Some values will be displayed twice, some values inserted in the
  queue will be lost. Search on final states will still discover the error, because it will lead to more
  solutions than the previous program.

Running the same program with JDK don't expose the wrong behaviour.

LTL verification. In every state where "this" is of type BlockingQueue we have head <= tail:

  kjkompile.sh --threading-sync
  kjrun.sh --timeout=0 --ltlmc="[]Ltl (this instanceof BlockingQueue ->Ltl (this.head) <= (this.tail))" \
    ../model-check/73_examples/queue_4_threads_3_wrong.java > ltl.out

Result: false, 1m5s win, 30s linux. The counter-example path is displayed.
  In this case, with one producer and two consumer threads the incorrect algorithm generates a path that
    doesn't satisfy the formula.

We can also try the standard (larger) set of transitions for multi-threading.
  (Need at least 8 GB of heap allocated for that):

    export K_OPTS="-Xss64m -Xmx16384m -Xss8m"
    kjkompile.sh --threading
    kjrun.sh ...

  Result: false in 1m30s linux. Max memory usage: 7GB, output file size: 120MB.
*/
public class queue_4_threads_3_wrong {
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
