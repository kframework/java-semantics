public class return_11_try_throw_finally_ret {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f() = " + f());
  }

  int f() {
    try {
      System.out.println("try");
      throw new RuntimeException("abc");
    } finally {
      System.out.println("finally");
      if (true) return 3;
    }
  }
}
