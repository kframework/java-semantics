/*
Composite class-qualified expressions.
  Class A. Test the expressions:
  - val = A.b.c
  - A.b.c = val
*/

public class static_f_111_class_qual_composite {
  public static void main(String[] args) {
    System.out.println("A.b.c init= " + A.b.c);
    A.b.c = "A.b.c";
    System.out.println("A.b.c after assign= " + A.b.c);
    System.out.println("Done!");
  }
}

class A {
  static B b = new B();
}

class B {
  String c;
}
