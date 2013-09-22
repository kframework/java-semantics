// Example 57 from page 45 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example57 {
  public static void main(String[] args) {
    for (int i=1; i<=4; i++) {
      for (int j=1; j<=i; j++)
        System.out.print("*");
      System.out.println();
    }
  }
}

