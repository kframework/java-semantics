// Testing cast
// This program should execute but should not type check

class A {
  int x;

  void A() {
    x=10;
  }

  int getA() {
    return x;
  }
}

class B extends A {
  int x;

  void B() {
    super.A();
    x=20;
  }

  int getB() {
    return x;
  }
}

class main {
  void main(string[] args) {
    B b = new B();
    A a = (A)b;
    print("b.x = ", b.x, "\n");
    print("a.x = ", a.x, "\n");
    print("a.getB() = ", ((B)a).getB(), "\n");
    print("a.getA() = ", a.getA(), "\n");
    print("Done!","\n");
  }
}

// b.x = 20
// a.x = 10
// a.getB() = 20
// a.getA() = 10
// Done!
