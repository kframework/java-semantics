/*
B < A. Call to B: super.x.y simple.
*/

class A {
  Auxx x = new Auxx("A");
}
class B extends A {
  Auxx x = new Auxx("B");

  String callSuper() {
    return super.x.y;
  }
}

class Auxx {
  String y;

  Auxx(String id) {
    y = "Auxx.y from " + id;
  }
}

public class fields_21_super_chain {
  public static void main(String[] args) {
    System.out.println(new B().callSuper());
    System.out.println("Done!");
  }
}
