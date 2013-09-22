// Example 28 from page 23 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Point {
  int x, y;

  Point(int x, int y) { this.x = x; this.y = y; }

  Point(Point p) { this(p.x, p.y); }    // calls the above constructor

  void move(int dx, int dy) { x += dx; y += dy; }

  public String toString() { return "(" + x + ", " + y + ")"; }
}

