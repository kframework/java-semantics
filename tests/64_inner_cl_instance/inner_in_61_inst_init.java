/*
Inner class with instance initializer.
  O, A.O, O.v, A.<instance init>. Instance init is traced, accesses v.
  Instantiate A from main.
*/

public class inner_in_61_inst_init {
  public static void main(String[] args) {
    System.out.println("new O(1).new A():");
    new O(1).new A();
    System.out.println();
    System.out.println("new O(2).new A():");
    new O(2).new A();
    System.out.println("Done!");
  }
}

class O {

  int v = 1;

  O(int v) {
    this.v = v;
    System.out.println("O.O()");
  }

  class A {

    A() {
      System.out.println("O.A.A()");
    }

    {
      System.out.println("O.A.[instance_init]: v = " + v);
    }
  }
}
