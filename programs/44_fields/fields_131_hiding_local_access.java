/*
Fields hiding. Subclass/superclass with fields, same name, access from both base and derived class.
  Now fields are accessed locally, via unqualified expressions.
*/

class C1 {
  int x, y;

  C1() {}
  void setx1(int v) { x = v; }
  void sety1(int v) { y = v; }
  int getx1() { return x; }
  int gety1() { return y; }
}

class C2 extends C1 {
  int y;

  C2() {}
  void sety2(int v) { y = v; }
  int getx2() { return x; }
  int gety2() { return y; }
}

public class fields_131_hiding_local_access {
  public static void main(String[] args) {
    C2 o2 = new C2();
    o2.setx1(11);
    o2.sety1(12);
    o2.sety2(99);
    System.out.print(o2.getx1()+ " ");
    System.out.print(o2.gety1()+ " ");
    System.out.print(o2.getx2()+ " ");
    System.out.println(o2.gety2());
    System.out.println("Done!");
  }
}

// 11 12 11 99
// Done!
