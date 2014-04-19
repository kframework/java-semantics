/*
O, O.A. Instantiate inner class O.A, from the outer class O. Call inner class method test().
  test() accesses instance members of the enclosing class: v, f().
  Instantiate O twice, each O will instantiate a different A, producing different output values.
*/

public class inner_in_14_acc_instance_outer {
  public static void main(String[] args) {
    new O(1);
    new O(2);
    System.out.println("Done!");
  }
}

class O {

  int v;
  String f() {return "f(" + v + ")";}

  O(int id) {
    v = id;
    new A().test();
  }

  class A {

    A() {
    }

    void test() {
      System.out.println("O.A: v   = " + v);
      System.out.println("O.A: f() = " + f());
    }
  }
}
