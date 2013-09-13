interface I {
  void m(int i);
}

class A {
  public void m(int i) { }
}

public class Example5_1_3 extends A implements I {
  void test(int i) {
    m(i);
  }

  static public void main(String[] args) {
     Example5_1_3 b = new Example5_1_3();
     b.test(5);
  }
}
