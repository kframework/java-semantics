/*
Abstract methods and access modes.
  - a.A:
    - protected abstract f(short)
    - public abstract f(int)
    - public f(long)
  - a.B < A:
    - public f(short)
    - public f(int)
  - main:
    - call (A)B.f(byte) - should call f(int)
    - call (A)B.f(long) - should call f(long)
    - call (B)B.f(byte) - should call f(short)
    - call (B)B.f(long) - should call f(long)
*/

import a.*;

public class abstract_03_acc_modes {
  public static void main(String[] args) {
    B b = new B();
    ((A)b).f((byte)0);
    ((A)b).f((long)0);
    b.f((byte)0);
    b.f((long)0);
    System.out.println("Done!");
  }
}
