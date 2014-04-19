/*
Interface fields having modifiers:
    - public static final
    - final static public
    - public
    - static
    - final
    - (none)
    Possible expressions: Interface qualifier.
*/

public class interface_f_16_modifiers {
  public static void main(String[] args) {
    System.out.println(I1.a + " " + I1.b + " " + I1.c + " " + I1.d + " " + I1.e + " " + I1.f);
    System.out.println("Done!");
  }
}

interface I1 {
  public static final int a = 1;
  final static public int b = 2;
  public int c = 3;
  static int d = 4;
  final int e = 5;
  int f = 6;
}
