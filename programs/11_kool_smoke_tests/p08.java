class c1 {
  void c1() { }
  int m1() {
    return(m2());
  }
  int m2() { return 13; }
}

class c2 extends c1 {
  void c2() { }
  int m1() { return 22; }
  int m2() { return 23; }
  int m3() {
    return(super.m1());
  }
}

class c3 extends c2 {
  void c3() { }
  int m1() { return 32; }
  int m2() { return 33; }
}

public class main {
  void main(String[] args) {
    System.out.print((new c3()).m3());
  }
}

