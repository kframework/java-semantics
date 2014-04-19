/*
Fileds with initializer, all initialized with a constant expression.
*/

class A {
  int a = 2;
  int b = 4 + 5;
  int c = (int) 9876543210L;
}

public class field_init_201_const {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("" + a.a + " " + a.b + " " + a.c);
    System.out.println("Done!");
  }
}
