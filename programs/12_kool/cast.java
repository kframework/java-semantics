// Testing cast
// This program should execute but should not type check

class A {
  int x;

  A() {
    x=10;
  }

  int getA() {
    return x;
  }
}

class B extends A {
  int x;

  B() {
    super();
    x=20;
  }

  int getB() {
    return x;
  }
}

class main {
  main(String[] args) {
    B b = new B();
    A a = (A)b;
    System.out.println("b.x = "+ b.x);
    System.out.println("a.x = "+ a.x);
    System.out.println("a.getB() = "+ ((B)a).getB());
    System.out.println("a.getA() = "+ a.getA());
    System.out.println("Done!");
  }
}

public class cast {
  public static void main(String[] args) {
    new main(args);
  }
}

// b.x = 20
// a.x = 10
// a.getB() = 20
// a.getA() = 10
// Done!
