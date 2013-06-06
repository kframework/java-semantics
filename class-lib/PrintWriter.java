package java.io;

public class PrintWriter {
    public native void print(Object o);
    public native void print(long l);
    public native void print(boolean b);

    public void println() {
      print("\n");
    }

    public void println(Object o) {
      print(o + "\n");
    }

    public void println(long l) {
      print(l + "\n");
    }

    public void println(boolean b) {
      print(b + "\n");
    }
}
