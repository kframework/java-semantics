/*
Field with initializer, then instance initializer, initializing the same field, then constructor.
*/

class A {
  int a = 2;

  {
    System.out.println("inst init begin, a = " + a);
    a = 3;
  }

  A() {
    System.out.println("constr begin, a = " + a);
  }
}

public class inst_init_31 {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("Done!");
  }
}
