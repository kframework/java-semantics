/*
Ambiguously inherited fields:
  A < I3 < I2{v}, I1{v}
  Test the cases by object-qualified expression. Actual object of most derived type.
*/

public class interface_f_51_amb_inherited_1 {
  public static void main(String[] args) {
    A a = new A();
    System.out.println(((I1) a).v + " " + ((I2) a).v);
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 1;
}

interface I2 {
  int v = 2;
}

interface I3 extends I1, I2 {}

class A implements I3 {
}
