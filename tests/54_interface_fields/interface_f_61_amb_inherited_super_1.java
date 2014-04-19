/*
Resolution of ambiguously inherited fields through super:
  B < A{v}, I1{v}
  Test both cases calling super.f in B.
*/

public class interface_f_61_amb_inherited_super_1 {
  public static void main(String[] args) {
    System.out.println(new B().getSuperV());
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 1;
}

class A {
  static int v = 2;
}

class B extends A implements I1 {

  int getSuperV() {
    return super.v;
  }
}
