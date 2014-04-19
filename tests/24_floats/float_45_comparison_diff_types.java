/*
Comparison among different numeric types:
  - float == double
  - double == float
  - float == int
  - double == int
  - int == double
  - double == long
  - long == double
  - int == long
  - float != double
  - double != int
*/

public class float_45_comparison_diff_types {
  public static void main(String[] args) {
    float f = (float)0.0;
    double d = 0.0;
    int i = 0;
    long l = 0;
    System.out.println("All values are 0.");

    System.out.println("float == double: " + (f == d));
    System.out.println("double == float: " + (d == f));
    System.out.println("float == int: "    + (f == i));
    System.out.println("double == int: "   + (d == i));
    System.out.println("int == double: "   + (i == d));
    System.out.println("double == long: "  + (d == l));
    System.out.println("long == double: "  + (l == d));
    System.out.println("int == long: "     + (i == l));
    System.out.println("float != double: " + (f != d));
    System.out.println("double != int: "   + (d != i));

    System.out.println("Done!");
  }
}
