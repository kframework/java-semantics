/*
Static method lookup, all the forms:
  6 possible expressions:
  - unqualified in static context
  - unqualified in instance context
  - this.f()
  - super.f()
  - object.f()
  - Class.f()
  2 possible target contexts:
  - method defined in the target type/ current class
  - method inherited. Test all possibilities.
*/

public class static_m_106_lookup_general {
  public static void main(String[] args) {
    System.out.println("Static method defined in target class:");
    A a = new A();
    a.staticTestA();
    a.instTestA();
    a.thisQTestA();
    System.out.print("object.sf(): ");
    a.sf();
    System.out.print("A.sf():      ");
    A.sf();

    System.out.println("Static method defined in subclass:");
    B b = new B();
    b.staticTestB();
    b.instTestB();
    b.thisQTestB();
    System.out.print("object.sf(): ");
    b.sf();
    System.out.print("B.sf():      ");
    B.sf();

    System.out.println("Call static method with super qualifier:");
    C c = new C();
    b.superQTestB();
    c.superQTestC();

    System.out.println("Done!");
  }
}

class A {
  static void sf() {
    System.out.println("A.sf()");
  }

  void instTestA() {
    System.out.print("(inst A)sf():   ");
    sf();
  }

  static void staticTestA() {
    System.out.print("(static A)sf(): ");
    sf();
  }

  void thisQTestA() {
    System.out.print("(A)this.sf():   ");
    this.sf();
  }
}

class B extends A {

  void instTestB() {
    System.out.print("(inst B)sf():   ");
    sf();
  }

  static void staticTestB() {
    System.out.print("(static B)sf(): ");
    sf();
  }

  void thisQTestB() {
    System.out.print("(B)this.sf():   ");
    this.sf();
  }

  void superQTestB() {
    System.out.print("(B)super.sf():  ");
    super.sf();
  }
}

class C extends B {
  void superQTestC() {
    System.out.print("(C)super.sf():  ");
    super.sf();
  }
}
