/*
Final field. A simple final field. Initialized in constructor. Null semantics.
*/

class A {
  final int a;
  boolean b;

  A() {
    a = 12;
  }
}

public class fields_18_final {
  public static void main(String[] args) {
    A a = new A();
    a.b = true;
    System.out.println("" + a.a + " " + a.b);
    System.out.println("Done!");
  }
}
