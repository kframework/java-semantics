/*
Test that three methods may form one single overwriting chain,
      with first method being package mode, and the remaining two - protected.
    - a.A  public f, less specific.
    - a.A: package f
    - a.B: protected f
    - b.C: protected f
    - C < B < A
    - call: ((A)C).f, ((B)C).f, ((C)C).f , both from package a and from package b
      (where applicable).
*/

import a.*;
import b.*;

public class overl_overw_interplay_03 {
  public static void main(String[] args) {
    System.out.println("Overview: package a.A.f, protected a.B.f, protected b.C.f");
    new Test_in_a();
    new Test_in_b();

    System.out.println("Done!");
  }
}
