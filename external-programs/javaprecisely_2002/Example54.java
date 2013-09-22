// Example 54 from page 43 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example54 {
  public static void main(String[] args) {
    System.out.println(absolute(-12));
    System.out.println(absolute(12));
    System.out.println(absolute(0));
  }

  // Behaves the same as absolute on page~\pageref{pgm-absolute-conditional}: 
  static double absolute(double x) { 
    if (x >= 0)
      return x;
    else 
      return -x;
  }
}

