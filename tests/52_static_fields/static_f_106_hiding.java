/*
Static field hiding:
  We have 6 modes to access a static field:
    - unqualified f in static context
    - unqualified f in instance context
    - this.f
    - object.f
    - Class.f
    - super.f
  We have three hiding scenarios involving static fields:
    - static hides static field
    - static hides instance
    - instance hides static
  We should test every combination that passes static checking.
*/

public class static_f_106_hiding {
  public static void main(String[] args) {
    A.a = 1;
    A.c = 3;
    B.a = 4;
    B.b = 5;

    C c = new C();

    System.out.println("Access fields in the context of class A:");
    c.staticTestA();
    c.instTestA();
    c.thisQTestA();
    System.out.print("a.field:        ");
    System.out.println("a=" + ((A)c).a + " b=" + ((A)c).b + " c=" + ((A)c).c);
    System.out.print("A.field:        ");
    System.out.println("a=" + A.a + " c=" + A.c);

    System.out.println("\nAccess fields in the context of class B:");
    c.staticTestB();
    c.instTestB();
    c.thisQTestB();
    System.out.print("b.field:        ");
    System.out.println("a=" + ((B)c).a + " b=" + ((B)c).b + " c=" + ((B)c).c);
    System.out.print("B.field:        ");
    System.out.println("a=" + B.a + " b=" + B.b);
    c.superQTestB();

    System.out.println("\nAccess fields in the context of class C:");
    c.staticTestC();
    c.instTestC();
    c.thisQTestC();
    System.out.print("c.field:        ");
    System.out.println("a=" + c.a + " b=" + c.b + " c=" + c.c);
    System.out.print("C.field:        ");
    System.out.println("a=" + C.a + " b=" + C.b);
    c.superQTestC();

    System.out.println("Done!");
  }
}

class A {
  static int a;
  int b = 2;
  static int c;

  void instTestA() {
    System.out.print("(inst A):       ");
    System.out.println("a=" + a + " b=" + b + " c=" + c);
  }

  static void staticTestA() {
    System.out.print("(static A)field:");
    System.out.println("a=" + a + " c=" + c);
  }

  void thisQTestA() {
    System.out.print("(A)this.field:  ");
    System.out.println("a=" + this.a + " b=" + this.b + " c=" + this.c);
  }
}

class B extends A {

  static int a;
  static int b;
  int c = 6;

  void instTestB() {
    System.out.print("(inst B)field:  ");
    System.out.println("a=" + a + " b=" + b + " c=" + c);
  }

  static void staticTestB() {
    System.out.print("(static B)field:");
    System.out.println("a=" + a + " b=" + b);
  }

  void thisQTestB() {
    System.out.print("(B)this.field:  ");
    System.out.println("a=" + this.a + " b=" + this.b + " c=" + this.c);
  }

  void superQTestB() {
    System.out.print("(B)super.field: ");
    System.out.println("a=" + super.a + " b=" + super.b + " c=" + super.c);
  }
}

class C extends B {

  void instTestC() {
    System.out.print("(inst C)field:  ");
    System.out.println("a=" + a + " b=" + b + " c=" + c);
  }

  static void staticTestC() {
    System.out.print("(static C)field:");
    System.out.println("a=" + a + " b=" + b);
  }

  void thisQTestC() {
    System.out.print("(C)this.field:  ");
    System.out.println("a=" + this.a + " b=" + this.b + " c=" + this.c);
  }

  void superQTestC() {
    System.out.print("(C)super.field: ");
    System.out.println("a=" + super.a + " b=" + super.b + " c=" + super.c);
  }
}

