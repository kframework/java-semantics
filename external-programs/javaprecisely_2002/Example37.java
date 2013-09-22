// Example 37 from page 31 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example37 {
  public static void main(String[] args) {
    int max = 2147483647;
    int min = -2147483648;
    println(max+1);                             // Prints -2147483648
    println(min-1);                             // Prints  2147483647
    println(-min);                              // Prints -2147483648
    print(   10/3); println(   10/(-3));        // Prints  3 -3
    print((-10)/3); println((-10)/(-3));        // Prints -3  3
    print(   10%3); println(   10%(-3));        // Prints  1  1
    print((-10)%3); println((-10)%(-3));        // Prints -1 -1
  }

  static void print(int i)   { System.out.print(i + " "); }

  static void println(int i) { System.out.println(i + " "); }
}

