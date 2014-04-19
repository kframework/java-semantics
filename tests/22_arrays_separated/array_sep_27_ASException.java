/*
ArrayStoreException.
  - Example from JLS $10.10, adapted to currently implemented features.
    ColoredPoint[] cpa = new ColoredPoint[10];
    Point[] pa = ColoredPoint[];
    pa[0] = new Point(); - ASException

  - additional: P[] CP[0] = new P2(); - assign different type, incompatible with
    array object type.
*/

class Point { int x, y; }

class ColoredPoint extends Point { int color; }

class Point2 extends Point{}

public class array_sep_27_ASException {
  public static void main(String[] args) {
    ColoredPoint[] cpa = new ColoredPoint[10];
    Point[] pa = cpa;
    pa[1] = null;
    System.out.println(pa[1] == null);
    try {
      pa[0] = new Point();
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    try {
      pa[0] = new Point2();
      System.out.println("ok");
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}
