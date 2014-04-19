/*
Field default values. Class with fields of all relevant types, without initializer.
Test their value.
*/

class A {
  byte b;
  short s;
  int i;
  long l;
  char ch;
  boolean bool;
  String str;
  RuntimeException re;
}

public class fields_16_default_value {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("" + a.b + " " + a.s + " " + a.i + " " + a.l + " " + a.ch + " " + a.bool
                    + " " + a.str + " " + a.re + " ");
    System.out.println("Done!");
  }
}
