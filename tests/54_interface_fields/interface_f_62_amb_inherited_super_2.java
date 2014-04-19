/*
Resolution of ambiguously inherited fields through super:
  B < (A, I2{v}), A < I1{v}
  Test both cases calling super.f in B.
*/

public class interface_f_62_amb_inherited_super_2 {
  public static void main(String[] args) {
    System.out.println(new B().getSuperV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 1;
}

interface I2 {
  int v = 2;
}

class A implements I1 {}

class B extends A implements I2 {

  int getSuperV() {
    return super.v;
  }
}
