package java.io;

public class PrintWriter {
    public native void print(String s);
    public native void print(long l);
    public native void print(boolean b);

    public void print(Object o) {
      if (o == null) {
        print("null");
      } else {
        print(o.toString());
      }
    }

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
