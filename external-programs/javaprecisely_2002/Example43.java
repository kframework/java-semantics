// Example 43 from page 33 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example43 {
  public static void main(String[] args) {
    System.out.println(absolute(-12));
    System.out.println(absolute(12));
    System.out.println(absolute(0));
  }

  // Returns the absolute value of x (always non-negative)
  static double absolute(double x) 
  { return (x >= 0 ? x : -x); }
}

