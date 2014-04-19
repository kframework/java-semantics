/*
Static methods hiding.
  A < B, A.f() =sig B.f(). Other variations by need.
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

  Method hiding is described in: $8.4.8.2, $8.4.8.3
*/

public class static_m_112_hiding {
  public static void main(String[] args) {
    C c = new C();

    System.out.println("Call methods in the context of class A:");
    c.staticTestA();
    c.instTestA();
    c.thisQTestA();
    System.out.print("object.sf(): ");
    ((A)c).sf();
    System.out.print("A.sf():      ");
    A.sf();

    System.out.println("Call methods in the context of class B:");
    c.staticTestB();
    c.instTestB();
    c.thisQTestB();
    System.out.print("object.sf(): ");
    ((B)c).sf();
    System.out.print("B.sf():      ");
    B.sf();
    c.superQTestB();

    System.out.println("Call methods in the context of class C:");
    c.staticTestC();
    c.instTestC();
    c.thisQTestC();
    System.out.print("object.sf(): ");
    c.sf();
    System.out.print("C.sf():      ");
    C.sf();
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

  static void sf() {
    System.out.println("B.sf()");
  }

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

  void instTestC() {
    System.out.print("(inst C)sf():   ");
    sf();
  }

  static void staticTestC() {
    System.out.print("(static C)sf(): ");
    sf();
  }

  void thisQTestC() {
    System.out.print("(C)this.sf():   ");
    this.sf();
  }

  void superQTestC() {
    System.out.print("(C)super.sf():  ");
    super.sf();
  }
}

