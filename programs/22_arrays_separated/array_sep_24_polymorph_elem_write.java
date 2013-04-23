/*
Polimorphic array assignment, element read and element write.
  - RuntimeException[] vre = NullPointerException[]. assign. read.
  - O[] RE[0] = new NPE[] - assigning to array element a more derived type than
    aray object type. Permitted.
*/

public class array_sep_24_polymorph_elem_write {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    A[] vre = new A[1];
    vre[0] = new B();
    vre[0].id = 1;
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