class c1 {
  void c1() { }
  int m1() { return 1; }
  int m2() { return m1(); }
}

class c2 extends c1 {
  void c2() { }
  int m1() { return 2; }
}

public class main {
  void main(String[] args) {
    c1 o1 = new c1();
    c2 o2 = new c2();
    System.out.print("" + o1.m1() + o2.m1() + o2.m2());
  }
}

