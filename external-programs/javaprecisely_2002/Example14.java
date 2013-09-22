// Example 14 from page 13 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example14 {
  public static void main(String[] args) {
    // Two ways to create a rectangular array of the form
    // 0.0 0.0 
    // 0.0 0.0 
    // 0.0 0.0 

    double[][] r1 = new double[3][2];

    double[][] r2 = new double[3][];
    for (int i=0; i<3; i++)
      r2[i] = new double[2];

    // Three ways to create a lower triangular array of the form
    // 0.0 
    // 0.0 0.0 
    // 0.0 0.0 0.0

    double[][] t1 = new double[3][];
    for (int i=0; i<3; i++)
      t1[i] = new double[i+1];
    
    // A nested array initializer creating an array of the above shape
    double[][] t2 = { { 0.0 }, { 0.0, 0.0 }, { 0.0, 0.0, 0.0 } };

    // Creating an anonymous array of the above shape
    double[][] t3 = new double[][] { { 0.0 }, { 0.0, 0.0 }, { 0.0, 0.0, 0.0 } };
  }
}

