/*
Classes S, O < S, O.A. Access members of S from A.
*/

public class inner_in_21_acc_outer_base {
  public static void main(String[] args) {
    new O().new A().test();
    System.out.println("Done!");
  }
}

class S {
    int v = 1;
    String f() {return "f()";}
}

class O extends S {

  class A {
    void test() {
      System.out.println("O.A: v   = " + v);
      System.out.println("O.A: f() = " + f());
    }
  }
}
