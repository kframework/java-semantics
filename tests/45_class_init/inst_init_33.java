/*
Field, initializer, field, initializer, then constructor.
*/

class A {

  int a = 2;

  {
    print();
  }

  int b = 3;

  {
    print();
  }

  int c = 4;

  A() {
    print();
  }

  void print() {
    System.out.println(a + " " + b + " " + c);
  }
}

public class inst_init_33 {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("Done!");
  }
}
