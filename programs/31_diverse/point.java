//Test constructors and inheritance

class Point {
  int x, y;

  Point(int initx, int inity) {
    x = initx;
    y = inity;
  }

  void move(int dx, int dy) {
    x = x+dx;
    y = y+dy;
  }

  void printLocation() {
    System.out.println("x = "+ x+ ", "+ "y = "+ y);
  }
}

class ColorPoint extends Point {
  int color;

  ColorPoint(int initx, int inity, int initcolor) {
    super(initx, inity);
    color = initcolor;
  }

  void setColor(int c) {
    color = c;
  }

  void printColor() {
    System.out.println("color = "+ color);
  }
}

public class point {
  public static void main(String[] args) {
    Point p = new Point(3,4);
    ColorPoint cp = new ColorPoint(10,20,87);
    p.move(1,2);
    p.printLocation();
    cp.move(7, 8);
    cp.printLocation();
    cp.printColor();
    System.out.println("Done!");
  }
}

// x = 4, y = 6
// x = 17, y = 28
// color = 87
// Done!
