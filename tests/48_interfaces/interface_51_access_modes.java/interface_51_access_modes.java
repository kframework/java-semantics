/*
Access modes - test that all interface methods are public.
  a.A < a.I1.
  a.I1: public f(int), f(byte).
  Access I1 methods from main through A, I1.
*/

import a.*;

public class interface_51_access_modes {
  public static void main(String[] args) {
    A a = new A();
    a.f((byte)0);
    a.f((int)0);

    System.out.println();
    I1 i1 = (I1)a;
    i1.f((byte)0);
    i1.f((int)0);

    System.out.println("Done!");
  }
}

