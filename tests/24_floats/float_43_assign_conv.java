/*
Assignment conversion:
  - int assigned to float
  - int assigned to double

Test structure: an overloaded method with one argument of all possible numeric types, both integer and floating-point.
  The method prints the received argument.
  We'll call the method with an argument expression of type x+y, where one of x or y
  is float or double.
*/

public class float_43_assign_conv {
  public static void main(String[] args) {
    float f;
    System.out.print("f(float  f = 100) : ");
    f(f = 100);
    double d;
    System.out.print("f(double d = 100) : ");
    f(d = 100);
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
