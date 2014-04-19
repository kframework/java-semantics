/*
Three classes, all with fields with initializer and no-arg constructor. Test that the order is correct.
All the initializers print a message.
*/

class A {

  int a = f(1);

  {
    f(2);
  }

  A() {
    f(3);
  }

  int f(int p) {
    System.out.println("f(" + p + ")");
    return p;
  }
}

class B extends A {

  int a = f(21);

  {
    f(22);
  }

  B() {
    f(23);
  }
}

class C extends B {

  int a = f(31);

  {
    f(32);
  }

  C() {
    f(33);
  }
}

public class inst_init_41_hier_order {
  public static void main(String[] args) {
    C c = new C();
    System.out.println("Done!");
  }
}
