// Example 3 from page 7 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example3 {
  public static void main(String[] args) {
    int a, b, c;
    int x = 1, y = 2, z = 3;
    int ratio = z/x;
    final double PI = 3.141592653589;
    boolean found = false;
    final int maxyz;
    if (z > y) maxyz = z; else maxyz = y;
    System.out.println(maxyz);
  }
}

