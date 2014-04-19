/*
Multiple-inherited field.
  I4 < I3, I2 < I1{v}
  We will test unqualified and I4-qualified exp.
*/

public class interface_f_41_multi_inh_multi_path_1 {
  public static void main(String[] args) {
    System.out.println(I4.v + " " + new A().getV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 1;
}

interface I2 extends I1 {}
interface I3 extends I1 {}
interface I4 extends I2, I3 {}

class A implements I4 {
  int getV() {
    return v;
  }
}
