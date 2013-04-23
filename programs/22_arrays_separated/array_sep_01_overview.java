/*
Array allocation by new, value assignment and value read:
  - int
  - A
*/

class A {
  int id;
  void print() {
    System.out.println("A:" + id);
  }
}

public class array_sep_01_overview {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] vi = new int[2];
    for(int i=0; i< 2; i++) {
      vi[i] = i;
      System.out.println(vi[i]);
    }

    A[] vre = new A[2];
    for(int i=0; i< 2; i++) {
      vre[i] = new A();
      vre[i].id = i;
      A a = vre[i];
      a.print();
    }
  }
}
