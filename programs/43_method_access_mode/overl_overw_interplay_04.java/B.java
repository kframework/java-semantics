/*
    - b.B: protected f
*/

package b;

import a.*;

public class B extends A {

  protected void f(int a) {
    System.out.println(" - b.B.f(int)  ");
  }
}
