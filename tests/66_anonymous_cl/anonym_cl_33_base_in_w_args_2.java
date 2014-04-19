/*
Base class is inner class from the same lexical hierarchy, have traced a constructor with two arguments.
  Anonymous class have a constructor with two arguments, one for each base argument.
  Anonymous class's test() calls super.test() that prints something from its enclosing class.
  Instantiate two anonymous derived from inner, for two enclosing objects: this and another one.
*/

public class anonym_cl_33_base_in_w_args_2 {
  public static void main(String[] args) {
    new O(10).test();
    System.out.println("Done!");
  }
}

class O {

  int var;

  O(int var) {
    this.var = var;
  }

  class A {

    int a, b;

    A(int a, int b) {
      System.out.println("A: a = "+ a + ", b = "+ b + ", O.this.var = "+ O.this.var);
      this.a = a;
      this.b = b;
    }

    void test() {
      System.out.println("A.test: a = "+ a + ", b = "+ b + ", O.this.var = "+ O.this.var);
    }
  }

  void test() {

    A a = O.this.new A(3, 4) {
      public void test() {
        System.out.println("anon: " + "O.this.var = "+ O.this.var);
        super.test();
      }
    };

    a.test();

    O o = new O(20);

    o.new A(5, 6) {
      public void test() {
        System.out.println("anon: " + "O.this.var = "+ O.this.var);
        super.test();
      }
    }.test();
  }
}
