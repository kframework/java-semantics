/*
Polymorphic array assignment, element read.
  NPE[] va; init a.
  RE[] vb = va; read vb.
*/

public class array_sep_23_polymorph_elem_read {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    B[] b = new B[1];
    b[0] = new B();
    b[0].id=1;

    A[] vre = b;
    printArray(vre);
  }

  void printArray(A[] v1) {
    for(int i=0; i<1; i++) {
      v1[i].print();
    }
    System.out.println();
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

class C extends B{}
