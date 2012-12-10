/*
Single-type imports and type import on demand mix. No name collisions.
  Classes p1.A, p1.B, p1.C, p2.B, p2.C, p3.C.
  From Main import: p1.A, p3.*, p2.B. Test A,B,C from Main.
*/

import p1.A;
import p3.*;
import p2.B;

public class packages_46_import_types_mix {
  public static void main(String[] args) {
    System.out.println("main   : A = " + new A());
    System.out.println("main   : B = " + new B());
    System.out.println("main   : C = " + new C());
    System.out.println("Done!");
  }
}
