/*
B < A. Call to B: super.x.y simple.
*/

class A {
  Aux x = new Aux("A");
}
class B extends A {
  Aux x = new Aux("B");

  String callSuper() {
    return super.x.y;
  }
}

class Aux {
  String y;

  Aux(String id) {
    y = "Aux.y from " + id;
  }
}

public class fields_21_super_chain {
  public static void main(String[] args) {
    System.out.println(new B().callSuper());
    System.out.println("Done!");
  }
}
