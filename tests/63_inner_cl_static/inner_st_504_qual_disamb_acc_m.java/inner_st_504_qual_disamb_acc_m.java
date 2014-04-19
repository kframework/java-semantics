/*
Inner class disambiguation with outer class access modes.
  classes:
    - public p1.A, public p1.A.C
    - package p1.B, public p2.B.C
    - package p2.A, public p2.A.C
    - public p2.B, public p2.B.C
  main class imports p1.*, p2.* Instantiate from main:
    - new A.C()
    - new B.C()
*/

import p1.*;
import p2.*;

public class inner_st_504_qual_disamb_acc_m {

  public static void main(String[] args) {
    System.out.println(new A.C());
    System.out.println(new B.C());
    System.out.println("Done!");
  }
}

