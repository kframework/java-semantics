/*
  Field hiding with access modes. Private fields hides a public field.
This case don't really have a runtime semantics.
It is impossible to distinguish between field access modes at runtime.
If an attempt is made to access a private field which hides a public field,
a compile-time error will be thrown.
  Here we test that is is possible to have access modifiers for fields.
*/

class A {
  public boolean a = false;
}

class B extends A {
  private int a = 10;

  int getA() {
    return a;
  }

  boolean getSuperA() {
    return super.a;
  }
}

public class fields_134_hiding_acc_modes {
  public static void main(String[] args) {
    B b = new B();
    System.out.println(b.getA() + " " + b.getSuperA() + " " + ((A) b).a);
    // b.a - compile-time error
    System.out.println("Done!");
  }
}
