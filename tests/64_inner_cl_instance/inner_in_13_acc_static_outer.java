/*
O, O.A. Instantiate inner class from the outer class. Inner class constructor accesses its members:
  field, method.
*/

public class inner_in_13_acc_static_outer {
  public static void main(String[] args) {
    new O();
    System.out.println("Done!");
  }
}

class O {

  static int v = 1;
  static String f() {return "f()";}

  O() {
    new A();
  }

  class A {

    A() {
      System.out.println("O.A: v   = " + v);
      System.out.println("O.A: f() = " + f());
    }
  }
}
