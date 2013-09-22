// Example 25 from page 21 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example25 {
  double m(int i) { return i; }
  boolean m(boolean b) { return !b; }
  static double m(int x, double y) { return x + y + 1; }
  static double m(double x, double y) { return x + y + 3; }

  public static void main(String[] args) { 
    System.out.println(m(10, 20));              // Prints 31.0
    System.out.println(m(10, 20.0));            // Prints 31.0
    System.out.println(m(10.0, 20));            // Prints 33.0
    System.out.println(m(10.0, 20.0));          // Prints 33.0
  }
}

