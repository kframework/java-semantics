/*
Promotions involving double:
  - byte + double
  - short + double
  - int + double
  - long + double
  - char + double
  - float + double
  - double + double
  - double + int

Test structure: an overloaded method with one argument of all possible numeric types, both integer and floating-point.
  The method prints the received argument.
  We'll call the method with an argument expression of type x+y, where one of x or y
  is float or double.
*/

public class float_42_promotions_with_double {
  public static void main(String[] args) {
    System.out.print("byte + double: ");
    f(((byte) 100) + 1.0);
    System.out.print("short + double: ");
    f(((short) 100) + 1.0);
    System.out.print("int + double: ");
    f(((int) 100) + 1.0);
    System.out.print("long + double: ");
    f(((long) 100) + 1.0);
    System.out.print("char + double: ");
    f(((char) 100) + 1.0);
    System.out.print("float + double: ");
    f(((float) 100) + 1.0);
    System.out.print("double + double: ");
    f(((double) 100) + 1.0);
    System.out.print("double + int: ");
    f(1.0 + 100);
    System.out.println("Done!");
  }

  static void f(byte a) {
    System.out.println("byte   a = " + a);
  }

  static void f(short a) {
    System.out.println("short  a = " + a);
  }

  static void f(int a) {
    System.out.println("int    a = " + a);
  }

  static void f(long a) {
    System.out.println("long   a = " + a);
  }

  static void f(char a) {
    System.out.println("char   a = " + a);
  }

  static void f(float a) {
    System.out.println("float  a = " + a);
  }

  static void f(double a) {
    System.out.println("double a = " + a);
  }
}
