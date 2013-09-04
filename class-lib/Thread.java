package java.lang;

public class Thread implements Runnable {

  private static int nextTid = 1;

  private Runnable runnable;
  private int tid = nextTid++;

  public Thread() {
    this.runnable = this;
  }

  public Thread(Runnable runnable) {
    this.runnable = runnable;
  }

  public void run() {}

  public void start() {
    startImpl(tid);
  }

  private native void startImpl(int tid);

  public synchronized void join() throws InterruptedException {
    joinImpl(tid);
  }

  public native void joinImpl(int tid) throws InterruptedException;

  public native void interrupt();
  public static native Thread currentThread();
}
