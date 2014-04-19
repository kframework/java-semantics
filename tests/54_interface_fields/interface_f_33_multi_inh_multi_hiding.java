/*
Multiple interface inheritance with indirect multi-hiding.
  I4 < I3{v} < (I2{v}, I1{v}) - I3.v hides both I1.v and I2.v

  Test using interface-qualified expression.
*/

public class interface_f_33_multi_inh_multi_hiding {
  public static void main(String[] args) {
    System.out.println(I1.v + " " + I2.v + " " +I3.v + " " + I4.v);
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 11;
}

interface I2 {
  int v = 12;
}

interface I3 extends I1, I2 {
  int v = 13;
}

interface I4 extends I3 {}
