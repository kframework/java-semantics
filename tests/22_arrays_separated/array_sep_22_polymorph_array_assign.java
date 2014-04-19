/*
Polymorphic array assignment.
  NPE[] va; init a.
  RE[] vb = va.
  va == vb?
*/

public class array_sep_22_polymorph_array_assign {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    B[] vnpe = new B[2];
    vnpe[1] = new B();
    vnpe[1].id = 1;

    A[] vre = vnpe;
    System.out.println(vnpe == vre);
  }
}

class A {
  int id;
  void print() {
    System.out.println("A:" + id);
  }
}

class B extends A{}
class C extends B{}
