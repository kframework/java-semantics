// Example 38 from page 31 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example38 {
  public static void main(String[] args) {
    System.out.println(leapyear(1900));
    System.out.println(leapyear(1999));
    System.out.println(leapyear(2000));
    System.out.println(leapyear(2001));
    System.out.println(leapyear(2004));
    System.out.println(leapyear(2100));
  }

  // Returns true if y is a leap year
  static boolean leapyear(int y) 
  { return y % 4 == 0 && y % 100 != 0 || y % 400 == 0; }
}

