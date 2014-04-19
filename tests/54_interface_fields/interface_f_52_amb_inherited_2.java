/*
Ambiguously inherited fields:
  B < A{v}, I1{v}
  Test the cases by object-qualified expression. Actual object of most derived type.
*/

public class interface_f_52_amb_inherited_2 {
  public static void main(String[] args) {
    B b = new B();
    System.out.println(((I1) b).v + " " + ((A) b).v);
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 1;
}

class A {
  static int v = 2;
}

class B extends A implements I1 {}
