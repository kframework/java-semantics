class A {
  int i = 0;
}

class B extends A {
  int i = 1;
}

class Test {
  public static void main(String[] args) {
    B b = new B();
    System.out.println(b.i);
    System.out.println(((A)b).i);
  }
}
