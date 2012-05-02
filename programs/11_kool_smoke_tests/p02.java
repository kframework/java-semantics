class c {
  int x;
  void c() {  // constructor method, so no need to type it
    x=5;
  }
  int g() {
    return x;
  }
}

class main {
  void main(string[] args) {
    print((new c()).g());
  }
}
