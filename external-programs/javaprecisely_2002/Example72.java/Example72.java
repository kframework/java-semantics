// Example 72 from page 53 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)

//Removed drawing, retained just PrintColors.

import java.awt.*;

class Example72 {
  static void printcolors(Colored[] cs) {
    for (int i=0; i<cs.length; i++)
      System.out.println(cs[i].getColor().toString());
  }

  public static void main(String[] args) {
    final ColoredDrawable[] cs =
          { new ColoredDrawablePoint(3, 4, Color.red),
            new ColoredRectangle(50, 100, 60, 110, Color.green) };
    printcolors(cs);
  }
}
