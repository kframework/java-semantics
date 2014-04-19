/*
O, O.A. Instantiate inner class from the outer class, using a qualified constructor call
  with qualifier being other than "this", and also with qualifier this.
  Inner class method test() calls both its members and instance members of the enclosing class.
  Check that outer members belong to the proper enclosing instance.
*/

public class inner_in_17_diff_constr_quals {
  public static void main(String[] args) {
    O o = new O(10);
    o.instAOnThis().test();
    o.instAOnOther().test();
    System.out.println("Done!");
  }
}

class O {

  int v;

  String f() {
    return "O[v=" + v + "].f()";
  }

  O(int id) {
    v = id;
  }

  A instAOnThis() {
    return this.new A(1);
  }

  A instAOnOther() {
    return new O(20).new A(2);
  }

  class A {
    int va;

    String fa() {
      return "A[va=" + va + "].fa()";
    }

    A(int id) {
      va = id;
    }

    void test() {
      System.out.println("O.A: v    = " + v);
      System.out.println("O.A: f()  = " + f());
      System.out.println("O.A: va   = " + va);
      System.out.println("O.A: fa() = " + fa());
    }
  }
}
