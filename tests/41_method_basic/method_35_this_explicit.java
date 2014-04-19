// Testing the explicit use of "this" to call a method.

class C {
  int m1() {
    return this.m2();
  }
  int m2() {
    return 13;
  }
}

class method_35_this_explicit {
  public static void main(String[] args) {
    System.out.println((new C()).m1());
    System.out.println("Done!");
  }
}

// 13
