// Example 40 from page 33 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example40 {
  public static void main(String[] args) {  
    double d;
    d = 12;                     // widening conversion from int to double

    byte b1 = 123, b2;          // narrowing int to byte
    b2 = 123 + 1;               // legal  : 123+1 is a compile-time constant
 // b2 = b1  + 1;               // illegal: (b1 + 1) has type int
    b2 = (byte)(b1 + 1);        // legal  : (byte)(b1 + 1) has type byte
 // b2 = 123 + 5;               // illegal: 123 + 5 is larger than 127

    int x = 0;
    x += 1.5;                   // add 1 to x
    d += 1.5;                   // add 1.5 to d
    System.out.println(x);
    System.out.println(d);
  }
}
