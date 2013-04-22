class A {
  private String m() {
   return "A/m()";
  }

  public String n() {
   return "A/n()";
  }

  void test() {
    System.out.println(this.m());
    System.out.println(this.n());
  }
}

class B extends A {
  public String m() {
   return "B/m()";
  }

  public String n() {
    return "B/n()";
  }
}

class Test {
  public static void main(String[] args) {
    B b = new B();
    b.test();
  }
}
