/*
Fields with initializer, calling an overridden method from subclass. The method
references fileds in the subclass which have initializers. The test should expose default values
of the fields in the subclass.
It is not clear from JLS what version of method should be called. I suppose that polymorphism
applies in field initializer context.
*/

class A {
  int a = f();

  int f() {
    System.out.println("A.f()");
    return 3;
  }
}

class B extends A {

  int x = 17;

  int f() {
    System.out.println("B.f()");
    return x;
  }
}

public class field_init_208_overriding {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("" + b.a);
    System.out.println("Done!");
  }
}
