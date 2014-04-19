/*
Matrix polymorphism.
    Object[][] mo = new RuntimeException[][];
    mo[0] = new NPE[]. read, write element.
*/

public class array_sep_25_polymorph_matrix {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    A[][] mo = new B[1][1];
    mo[0] = new C[2];
    mo[0][0] = new C();
    mo[0][0].id = 1;
    mo[0][0].print();
  }

}

class A {
  int id;
  void print() {
    System.out.println("A:" + id);
  }
}

class B extends A{
  void print() {
    System.out.println("B:" + id);
  }
}

class C extends B{
  void print() {
    System.out.println("C:" + id);
  }
}
