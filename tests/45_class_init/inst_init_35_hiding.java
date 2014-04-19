/*
Inst initializer with a local var shadowing a field.
*/

class A {

  int a = 2;

  {
    int a = 29;
    System.out.println(a);
  }

  {
    System.out.println(a);
  }

  A() {
    System.out.println(a);
  }
}

public class inst_init_35_hiding {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("Done!");
  }
}
