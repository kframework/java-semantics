/*
array.clone interaction with array polymorphism.
  - (RE[]) Object[] RE[].clone()
  - (RE[]) Object RE[].clone() - not possible because Object.clone() is protected.
  Case when object type is not the actual array type - it is another array
      or just Object. Important for semantics of this method.
    We just check that what is returned can be cast to the runtime clone result type.
    Compile-time type may only be checked with method overloading.
*/

public class array_19_clone_polymorphism {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    RuntimeException[] vre = new RuntimeException[2];
    vre[0] = null;
    vre[1] = new RuntimeException("re");

    Object[] vo = vre;
    RuntimeException[] clone1 = (RuntimeException[]) vo.clone();
    cloneTest(clone1,vre);
  }

  void cloneTest(RuntimeException[] v1, RuntimeException[] v2) {
    System.out.print((v1 == v2)+" : ");
    for(int i=0; i<v1.length; i++) {
      System.out.print((v1[i] == v2[i]) + " ");
    }
    System.out.println();
  }
}
