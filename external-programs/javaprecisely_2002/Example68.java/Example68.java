// Example 68 from page 51 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)

import java.util.Scanner;

class Example68 {
  public static void main(String[] args) {
    Scanner scanner = new Scanner(System.in);
    int x = scanner.nextInt();
    System.out.println("Integer square root of " + x + " is " + sqrt(x));
  }

  // Modified for Java from C code on Paul Hsieh's square root page

  static int sqrt(int x) {  // Algorithm by Borgerding, Hsieh, Ulery
    if (x < 0)
      throw new IllegalArgumentException("sqrt: negative argument");
    int temp, y = 0, b = 0x8000, bshft = 15, v = x;;
    do {
      if (v >= (temp = (y<<1)+b << bshft--)) {
        y += b; v -= temp;
      }
    } while ((b >>= 1) > 0);
    assert (long)y * y <= x && (long)(y+1)*(y+1) > x;
    return y;
  }
}

