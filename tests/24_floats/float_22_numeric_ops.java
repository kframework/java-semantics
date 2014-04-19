/*
All numeric operators: unary +, -, binary *, /, %, +, - . Also ++, --, (prefix/postfix)
*/

public class float_22_numeric_ops {
  public static void main(String[] args) {
    System.out.println("+1.23 = " + (+1.23));
    System.out.println("-1.23 = " + (-1.23));
    System.out.println("7 * 1.2 = " + (7.0 * 1.2));
    System.out.println("7 / 1.2 = " + (7.0 / 1.2));
    System.out.println("7 % 1.2 = " + (7.0 % 1.2));
    System.out.println("7 + 1.2 = " + (7.0 + 1.2));
    System.out.println("7 - 1.2 = " + (7.0 - 1.2));

    double f = 1.23;
    System.out.println("++1.23  = " + (++f));

    f = 1.23;
    System.out.println("--1.23  = " + (--f));

    f = 1.23;
    System.out.println("(f = 1.23)++ = " + (f++));
    System.out.println("(f =           " + f);

    f = 1.23;
    System.out.println("(f = 1.23)-- = " + (f--));
    System.out.println("(f =           " + f);

    System.out.println("Done!");
  }
}
