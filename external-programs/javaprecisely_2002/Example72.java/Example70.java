// Example 70 from page 53 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)

import java.awt.*;

interface Colored { Color getColor(); }
interface Drawable { /*void draw(Graphics g);*/ }
interface ColoredDrawable extends Colored, Drawable {}

