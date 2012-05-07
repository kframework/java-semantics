class c1 {
  int v;
  void c1() { v=7;++v; }
  int m0()  { return v; }
  int m1()  { return -v; }
}

class c2 {
  int v;
  void c2(int x) { v=x; }
  int m0()  { return v; }
  int m1()  { return -v; }
}

class main {
  void main(String[] args) {
    c1 o1 = new c1();
    c2 o2 = new c2(1);
    System.out.print(o1.m0());
    o1.m0 = o1.m1;
    System.out.print(o1.m0());
    o1.m0 = o2.m0;
    System.out.print(o1.m0());
    o1.m0 = o2.m1;
    System.out.print(o1.m0());
    o2.c2(3);
    System.out.print(o1.m0());
  }
}

