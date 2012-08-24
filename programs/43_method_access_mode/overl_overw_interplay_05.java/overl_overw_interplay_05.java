/*
Test that in a hierarchy like a.C < b.B < a.A class C don't inherit a method from A
  with package access mode.
    - a.A  public f, less specific.
    - a.A: package f
    - a.A: pckage f, most specific.
    - b.B: package f
    - a.C: package f
    - C < B < A
    - call: ((A)C).f, ((B)C).f, ((C)C).f , both from package a and from package b.
*/

import a.*;
import b.*;

public class overl_overw_interplay_05 {
  public static void main(String[] args) {
    System.out.println("Overview: package a.A.f, package b.B.f, package a.C.f");
    new Test_in_a();
    new Test_in_b();

    System.out.println("Done!");
  }
}
