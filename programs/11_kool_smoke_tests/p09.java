class a {
  int i, j;
  void a() {
    i = 0;
    j = ++i+1;
  }
  int aa() {
    j = ++i+1;
    return j;
  }
  int f() {
    return aa();
  }
  int g() {
    return f();
  }
  int h() {
    return i+j;
  }
}

class b extends a {
  int j, k;
  int aa() {
    return bb();
  }
  void b() {
    super.a();
    j = 10;
    k = j+1;
  }
  int bb() {
    k = ++j+1;
    return k;
  }
  int g() {
    return super.h();
  }
  int h() {
    return g();
  }
}

class c extends b {
  int aa() {
    return super.aa();
  }
  int bb() {
    return super.bb();
  }
  void c() {
    i = 100;
    j = i+1;
    k = j+1;
  }
  int g() {
    return i+k*j;
  }
}

public class main {
  void p(a o) {
    System.out.print(o.f());System.out.print(o.g());System.out.print(o.h());
  }
  void main(String[] args) {
    p(new a());
    p(new b());
    p(new c());
  }
}

