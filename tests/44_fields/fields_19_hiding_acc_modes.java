/*
Field hiding with access modes. Private fields hides a public field.
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

public class fields_19_hiding_acc_modes {
  public static void main(String[] args) {
    B b = new B();
    System.out.println(b.getA() + " " + b.getSuperA() + " " + ((A) b).a);
    System.out.println("Done!");
  }
}
