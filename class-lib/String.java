package java.lang;

public class String {
  public native int length();
  public native char charAt(int index);
  public native static String valueOf(int i);
  public native boolean equals(Object anObject);
  public native String toString();
  public native int compareTo(Object another);
}
