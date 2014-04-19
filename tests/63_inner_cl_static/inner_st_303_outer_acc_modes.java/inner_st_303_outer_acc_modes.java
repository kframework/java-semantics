/*
Inner class to outer class access modes.
  Classes p1.P1A < p1.P1B < p2.P2C, p1.P1D, p1.P1A.Inner
  Classes p1.P1A, p1.P1B, p2.P2C, p1.P1D have overloaded methods f(), g(), h() and k()
  respectively, with diff access modes. Call all with argument byte from p1.P1A.Inner.
*/

public class inner_st_303_outer_acc_modes {

  public static void main(String[] args) {
    p1.P1A.Inner.test();
    System.out.println("Done!");
  }
}

