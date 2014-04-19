/*
A simple local class LB that extends a class A and prints something in the toString().
*/

public class local_cl_11_simple {
  public static void main(String[] args) {
    new O().container();
    System.out.println("Done!");
  }
}

class A {}

class O {

  void container() {
    class LB extends A {
      public String toString() {return "O.container().LB";}
    }

    System.out.println(new LB());
  }
}
