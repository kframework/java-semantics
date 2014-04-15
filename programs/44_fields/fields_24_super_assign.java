/*
B < A. Call to B: Assigning to super.x.
*/

class A {
  int x = 1;
}
class B extends A {
  int x = 0;

  int getSuperX() {
    return super.x;
  }

  void setSuperX(int x) {
    super.x = x;
  }
}

public class fields_24_super_assign {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("((A) b).x = " + ((A) b).x);
    b.setSuperX(2);
    System.out.println("((A) b).x = " + ((A) b).x);
    System.out.println("Done!");
  }
}
