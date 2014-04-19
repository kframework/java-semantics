/*
Inst initializer throwing exc. The remaining field inits and constructor are not executed.
*/

class A {

  int a = 2;

  {
    print();
  }

  int b = 3;

  {
    if (true) {
      throw new RuntimeException("re");
    }
  }

  int c = 4;

  A() {
    print();
  }

  void print() {
    System.out.println(a + " " + b + " " + c);
  }
}

public class inst_init_34_exc {
  public static void main(String[] args) {
    try {
      A a = new A();
    } catch (RuntimeException re) {
      System.out.println(re);
    }
    System.out.println("Done!");
  }
}
