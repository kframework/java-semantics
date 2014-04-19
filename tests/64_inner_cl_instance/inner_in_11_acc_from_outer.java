/*
O, O.A. Instantiate inner class from the outer class, access members: v, f().
*/

public class inner_in_11_acc_from_outer {
  public static void main(String[] args) {
    new O();
    System.out.println("Done!");
  }
}

class O {

  O() {
    A a = new A();
    System.out.println("O: a.v   = " + a.v);
    System.out.println("O: a.f() = " + a.f());
  }

  class A {
    int v = 1;
    String f() {return "A.f()";}
  }
}
