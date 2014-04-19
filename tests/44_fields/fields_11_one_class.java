/*
One class with fields.
*/

class A {
  int a;
  boolean b;
}

public class fields_11_one_class {
  public static void main(String[] args) {
    A a = new A();
    a.a = 2;
    a.b = true;
    System.out.println("" + a.a + " " + a.b);
    System.out.println("Done!");
  }
}
