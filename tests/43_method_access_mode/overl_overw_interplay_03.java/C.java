/*
    - b.C: protected f
*/

package b;

import a.*;

public class C extends B {

  protected void f(int a) {
    System.out.println(" - b.C.f(int)  ");
  }
}
