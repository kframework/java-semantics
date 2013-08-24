package java.lang;

public class Thread implements Runnable {

  private Runnable runnable;

  public Thread() {
    this.runnable = this;
  }

  public Thread(Runnable runnable) {
    this.runnable = runnable;
  }

  public void run() {}

  public native void start();
  public native synchronized void join() throws InterruptedException;
  public native void interrupt();
  public static native Thread currentThread();
}
