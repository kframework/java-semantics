/*
Instance initializer, then field initializer, initializing the same field, then constructor.
*/

class A {

  {
    System.out.println("inst init begin, a = " + this.a);
    a = 3;
  }

  int a = 2;

  A() {
    System.out.println("constr begin, a = " + a);
  }
}

public class inst_init_32 {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("Done!");
  }
}
