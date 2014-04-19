public class return_14_try_ret_finally_ret {

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
      return 1;
    } finally {
      System.out.println("finally");
      if (true) return 3;
    }
  }
}
