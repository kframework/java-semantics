/*
Subclass/superclass with fields, different names. Access from derived class.
*/

class A {
  int a;
  boolean b;
}

class B extends A {
  String s;
}

public class fields_12_inheritance {
  public static void main(String[] args) {
    B b = new B();
    b.a = 2;
    b.b = true;
    b.s = "abc";
    System.out.println("" + b.a + " " + b.b + " " + b.s);
    System.out.println("Done!");
  }
}
