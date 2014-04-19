/*
Promotions involving float:
  - byte + float
  - short + float
  - int + float
  - long + float
  - char + float
  - float + float
  - double + float
  - float + int

Test structure: an overloaded method with one argument of all possible numeric types, both integer and floating-point.
  The method prints the received argument.
  We'll call the method with an argument expression of type x+y, where one of x or y
  is float or double.
*/

public class float_41_promotions_with_float {
  public static void main(String[] args) {
    System.out.print("byte + float: ");
    f(((byte) 100) + 1.0f);
    System.out.print("short + float: ");
    f(((short) 100) + 1.0f);
    System.out.print("int + float: ");
    f(((int) 100) + 1.0f);
    System.out.print("long + float: ");
    f(((long) 100) + 1.0f);
    System.out.print("char + float: ");
    f(((char) 100) + 1.0f);
    System.out.print("float + float: ");
    f(((float) 100) + 1.0f);
    System.out.print("double + float: ");
    f(((double) 100) + 1.0f);
    System.out.print("float + int: ");
    f(1.0f + 100);
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
