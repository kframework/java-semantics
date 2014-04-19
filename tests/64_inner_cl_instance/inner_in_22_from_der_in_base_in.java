/*
Classes S, S.A, O < S, O.B. Instantiate A from B by simple name. Access members of A from B.
  Members of A access the members of S.
*/

public class inner_in_22_from_der_in_base_in {
  public static void main(String[] args) {
    new O().new B().test();
    System.out.println("Done!");
  }
}

class S {
    int v = 1;
    String f() {return "f()";}

  class A {
    int va = 10;
    String fa() {return "S[v=" + v + "].fa()";}
  }
}

class O extends S {

  class B {
    void test() {
      A a = new A();
      System.out.println("O.B: a.va   = " + a.va);
      System.out.println("O.B: a.fa() = " + a.fa());
    }
  }
}
