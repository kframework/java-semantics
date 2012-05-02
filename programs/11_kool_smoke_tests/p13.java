class c {
  void c() {  }
  void test() {
    print(-1);
    if (this instanceof c1) print(1);
    if (this instanceof c2) print(2);
    if (this instanceof c3) print(3);
  }
}

class c1 extends c {
  void c1() { super.c(); }
}

class c2 extends c {
  void c2() { super.c(); }
}

class c3 extends c {
  void c3() { super.c(); }
}

class main {
  void main(string[] args) {
    (new c()).test();
    (new c1()).test();
    (new c2()).test();
    (new c3()).test();
  }
}

