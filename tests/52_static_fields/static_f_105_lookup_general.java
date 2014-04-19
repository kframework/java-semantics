/*
Static field lookup, all the forms:
  We have 6 possible expressions:
    - unqualified f in static context
    - unqualified f in instance context
    - this.f
    - object.f
    - Class.f
    - super.f
  combined by two target contexts:
    - field in current class
    - field inherited from superclass.
*/

public class static_f_105_lookup_general {
  public static void main(String[] args) {
    A.sv = 8;

    System.out.println("Static field defined in target class:");
    A a = new A();
    a.staticTestA();
    a.instTestA();
    a.thisQTestA();
    System.out.println("a.sv="+a.sv);
    System.out.println("A.sv="+A.sv);

    System.out.println("\nStatic field defined in subclass:");
    B b = new B();
    b.staticTestB();
    b.instTestB();
    b.thisQTestB();
    System.out.println("b.sv="+b.sv);
    System.out.println("B.sv="+B.sv);

    System.out.println("\nAccess static field with super qualifier:");
    C c = new C();
    b.superQTestB();
    c.superQTestC();

    System.out.println("Done!");
  }
}

class A {
  static int sv;

  void instTestA() {
    System.out.println("(inst A)sv="+sv);
  }

  static void staticTestA() {
    System.out.println("(static A)sv="+sv);
  }

  void thisQTestA() {
    System.out.println("(A)this.sv="+this.sv);
  }
}

class B extends A {

  void instTestB() {
    System.out.println("(inst B)sv="+sv);
  }

  static void staticTestB() {
    System.out.println("(static B)sv="+sv);
  }

  void thisQTestB() {
    System.out.println("(B)this.sv="+this.sv);
  }

  void superQTestB() {
    System.out.println("(B)super.sv="+super.sv);
  }
}

class C extends B {
  void superQTestC() {
    System.out.println("(C)super.sv="+super.sv);
  }
}
