/*
Multifield. One field declaration with multiple fields.
*/

class A {
  int a,b,c;
}

public class fields_17_multifield {
  public static void main(String[] args) {
    A a = new A();
    a.a = 1;
    a.b = 2;
    a.c = 4;
    System.out.println("" + a.a + " " + a.b + " " + a.c);
    System.out.println("Done!");
  }
}
