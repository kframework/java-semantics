class i {
  int val;
  void i(int v) {
    val = v;
  }
  g m1() {
    return (new g(val+9));  // creates and returns an object
  }
}

class g {
  int a;
  void g(int t) {
    a = t;
  }
  void print2() { System.out.print(a); }
}

class main {
  void main(String[] args) {
    ((new i(1)).m1()).print2();
  }
}

