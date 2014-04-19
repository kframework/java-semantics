/*
Test whetner a method may extend two methods at the same time, one package and one protected.
    It is not clear whether this is really possible.
    - a.A  public f, less specific.
    - a.A: package f
    - b.B: protected f
    - a.C: protected f
    - C < B < A
    - call: ((A)C).f, ((B)C).f, ((C)C).f , both from package a and from package b
      (where applicable).
  This is the most interesting test. I'm not sure whether this test will compile.
  It seems that C.f() overwrites both A.f() and B.f() at the same time.
*/

import a.*;
import b.*;

public class overl_overw_interplay_04 {
  public static void main(String[] args) {
    System.out.println("Overview: package a.A.f, protected b.B.f, protected a.C.f");
    new Test_in_a();
    new Test_in_b();

    System.out.println("Done!");
  }
}
