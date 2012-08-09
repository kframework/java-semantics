/*
18. ArrayStoreException.
  - Example from JLS $10.10, adapted to currently implemented features.
*/

class Point { int x, y; }

class ColoredPoint extends Point { int color; }

public class array_18_ArrayStoreException {
  public static void main(String[] args) {
    ColoredPoint[] cpa = new ColoredPoint[10];
    Point[] pa = cpa;
    pa[1] = null;
    System.out.println(pa[1] == null);
    try {
      pa[0] = new Point();
    } catch (ArrayStoreException e) {
      System.out.println(e);
    }
  }
}
