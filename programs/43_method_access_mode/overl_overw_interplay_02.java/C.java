/*
    a.C: protected f
*/

package a;

import b.*;

public class C extends B {

  protected void f(int a) {
    System.out.print("a.C.f(int)  ");
  }
}
