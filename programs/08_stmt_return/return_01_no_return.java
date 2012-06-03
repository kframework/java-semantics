public class return_01_no_return {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("test.test()");
    f();
  }

  void f() {
    System.out.println("f()");
  }
}
