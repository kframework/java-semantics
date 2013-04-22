interface I {
  void m(int i);
}

class A {
  public void m(int i) { }
}

class B extends A implements I {
  void test(int i) {
    m(i);
  }

  static public void main(String[] args) { 
     B b = new B();
     b.test(5);
  }
}
