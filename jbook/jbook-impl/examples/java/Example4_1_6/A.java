interface I {
   int m(int i);
}

class B {
  int m(int i) {
    return i*i;
  }
}

class A extends B implements I {
  static void main(String args[]) { }
}
