public class Object {
    public native void notify();
    public native void notifyAll();
    public native void wait();
    public native boolean equals(Object o);
    public native Object clone();
    public native String toString();
}

public class Array implements Cloneable {
  public int length;
}

public class Throwable {
   String msg = "";
   public Throwable(String s) {
     msg = s;
   }

   public String toString() {
     if (msg.equals(""))
      return super.toString();
     else
      return (super.toString() + ": " + msg);
   }
}

interface Runnable {
    void run();
}

public class Thread extends Object implements Runnable {
    Thread () {
	target = this;
    }

    Thread (Runnable t) {
	target = t;
    }

    native public void start();
    native public void interrupt();
    native public static boolean interrupted();
    native public boolean isInterrupted();
    public void run()   { return; }

    private Runnable target;
}

public class String implements Comparable {
    String s;
    public String(String x) {
     s = x;
    }
    static native String valueOf(int i);
    static native String valueOf(char c);
    native int length();

    public int compareTo(Object o) {
	return 0;
    }
    public String toString() {
        return s;
    }
}

public class NullPointerException extends RuntimeException {
}

public class ArithmeticException extends RuntimeException {
}

public class ArrayIndexOutOfBoundsException extends IndexOutOfBoundsException {
}

public class ArrayStoreException extends RuntimeException {
}

public class IndexOutOfBoundsException extends RuntimeException {
}

public class NegativeArraySizeException extends RuntimeException {
}

public class IllegalThreadStateException extends RuntimeException {
}

public class RuntimeException extends Exception {
}

public class InterruptedException extends Exception {
}

public class CloneNotSupportedException extends Exception {
}

public class Exception extends Throwable {
   public Exception(String s) { super(s); }
}

public class Error extends Throwable {
}

public class LinkageError extends Error {
}

public class NoClassDefFoundError extends LinkageError {
}

public class ExceptionInInitializerError extends LinkageError {
}

public class ClassCastException extends RuntimeException {
}

public class ThreadDeath extends Error {
}

public class System {
  static PrintStream out = new PrintStream();
}

public class PrintStream {
    native void print(int i);
    native void print(String s);
    native void println(int i);
    native void println(boolean b);
    native void println(char c);
    native void println(float f);
    native void println(long l);
    native void println(double d);
    native void println(String s);
    void println(StringBuffer s) {
	println(s.toString());
    }
    void println(Object o) {
        if (o==null) println("null");
        else println(o.toString());
    }

    void println() {
	println("");
    }
}

public class StringBuffer {
    private String s;

    StringBuffer() {
	s = "";
    }

    StringBuffer(int length) {
	s = "";
    }

    StringBuffer(String str) {
	s = str;
    }

    StringBuffer append(char c) {
	s = s + c;
	return this;
    }

    StringBuffer append(String x) {
        s = s + x;
        return this;
    }

    int length() {
	return s.length();
    }

    public String toString() {
	return s;
    }
}

interface Cloneable {
}

interface Comparable {
    public int compareTo(Object o);
}

public class Number {
}

public class Integer extends Number implements Comparable {
    private int i;
    public Integer(int _i) {
      i = _i;
    }

    public String toString() {
      return String.valueOf(i);
    }

    public int compareTo(Object o) {
	return 0;
    }
}

public class Float extends Number implements Comparable {
    public Float(float f) {
    }

    public int compareTo(Object o) {
	return 0;
    }
}

