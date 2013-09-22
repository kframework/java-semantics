// Example 48 from page 37 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example48 {
  public static void main(String[] args) {
    System.out.println("Number of points created: " + SPoint.getSize());
    SPoint p = new SPoint(12, 123);
    SPoint q = new SPoint(200, 10);
    SPoint r = new SPoint(99, 12);
    SPoint s = p;
    q = null;
    System.out.println("Number of points created: " + SPoint.getSize());
    System.out.println("Number of points created: " + q.getSize());
    System.out.println("r is point number " + r.getIndex());
    for (int i=0; i<SPoint.getSize(); i++)
      System.out.println("SPoint number " + i + " is " + SPoint.getPoint(i));
  }
}
