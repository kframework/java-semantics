/*
Inner class qualifiers disambiguation with imports.
  classes: C, p1.B, p1.B.C, p2.B, p2.B.C
  from main import p2.*
  Instantiate:
    - C, B.C, p1.B.C.
*/

import p2.*;

public class inner_st_503_qual_disamb_import {

  public static void main(String[] args) {
    System.out.println(new C());
    System.out.println(new B.C());
    System.out.println(new p1.B.C());
    System.out.println("Done!");
  }
}

class C {
  public String toString() {
    return "[default].C";
  }
}

