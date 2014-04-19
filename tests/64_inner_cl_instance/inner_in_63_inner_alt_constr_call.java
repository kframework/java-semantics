/*
Inner class with alternate constructor call.
  Referencing fields of the outer class in the alternate constructor call of the inner class.
*/

public class inner_in_63_inner_alt_constr_call {
  public static void main(String[] args) {
    new O(2).new A();
    System.out.println("Done!");
  }
}

class O {

  int v = 1;

  O(int v) {
    this.v = v;
    System.out.println("O.O(" + v + ")");
  }

  public String toString() { return "O[v=" + v + "]";}

  class A {

    A() {
      this(v);
    }
    
    A(int a) {
      System.out.println("O.A.A(" + a + ")");
    }
  }
}
