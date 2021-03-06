/*
Test that the same class hierarchy may contain multiple method chains
    with the same signature, but with package mode and in different packages.
    Also, when a method in a chain extends it's access mode to protected, this
    does not affect the method chain above (in the superclasses).
    - a.A  public f, less specific.
    - a.A: package f
    - b.B: package f
    - a.C: protected f
    - C < B < A
    - call: ((A)C).f, ((B)C).f, ((C)C).f , both from package a and from package b
      (where applicable).
*/

import a.*;
import b.*;

public class overl_overw_interplay_02 {
  public static void main(String[] args) {
    System.out.println("Overview: package a.A.f, package b.B.f, protected a.C.f");
    new Test_in_a();
    new Test_in_b();

    System.out.println("Done!");
  }
}
