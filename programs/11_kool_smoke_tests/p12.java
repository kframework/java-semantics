class main {
  int f(int x) {
    if (x <= 1) return 1; else return(x * (f(x - 1)));
  }
  void main(string[] args) {
    print(f(f(4)));
  }
}

