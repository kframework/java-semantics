package p1;

import p2.*;

public class A{

  public void test() {
    System.out.println(A.class.getName());
    System.out.println(B.class.getName());
    System.out.println(C.class.getName());
    System.out.println(p2.C.class.getName());
  }
}

class B{}
