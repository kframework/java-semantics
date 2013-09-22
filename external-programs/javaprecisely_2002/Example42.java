// Example 42 from page 33 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example42 {
  public static void main(String[] args) {
    double[] a = { 365.0, 24.0, 60.0, 60.0 };
    System.out.println(multiply(a));
  }

  static double multiply(double[] xs) {
    double prod = 1.0;
    for (int i=0; i<xs.length; i++)
      prod *= xs[i];                    // Equivalent to: prod = prod * xs[i]
    return prod;
  }
}

