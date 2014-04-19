/*
Array of interfaces. - The "Shape" example of polymorphism.
  Interface: IShape
  Classes: Rectangle < IShape, Circle < IShape
  - function: maxArea(IShape[]) - returns the shape with the maximal area.
  - test the function in main().
*/

public class interface_71_array_of_intf_shapes {
  public static void main(String[] args) {
    IShape[]  shapes = new IShape[3];
    shapes[0] = new Rectangle(2, 4);
    shapes[1] = new Circle(3);
    shapes[2] = new Rectangle(3, 3);

    IShape maxShape = max(shapes);
    System.out.println("maxShape = " + maxShape);
    System.out.println("Done!");
  }

  public static IShape max(IShape[] shapes) {
    IShape maxShape = null;
    for(int i=0; i< shapes.length; i++) {
      if (maxShape == null || shapes[i].area() > maxShape.area()) {
        maxShape = shapes[i];
      }
    }
    return maxShape;
  }
}

interface IShape {
  int area();
}

class Rectangle implements IShape {
  int dx, dy;

  Rectangle(int dx, int dy) {
    this.dx = dx;
    this.dy = dy;
  }

  public int area() {
    return dx * dy;
  }

  public String toString() {
    return "Rectangle, dx = " + dx + ", dy = " + dy + ", area = " + area();
  }
}

class Circle implements IShape {
  static final int PI = 3; //in order to avoid messing with real numbers

  int r;

  Circle(int r) {
    this.r = r;
  }

  public int area() {
    return PI * r*r;
  }

  public String toString() {
    return "Circle, r = " + r + ", area = " + area();
  }
}
