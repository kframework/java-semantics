/*
    - a.B: protected f
*/

package a;

import a.*;

public class B extends A {

  protected void f(int a) {
    System.out.println(" - a.B.f(int)  ");
  }
}
