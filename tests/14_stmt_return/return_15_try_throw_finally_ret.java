public class return_15_try_throw_finally_ret {

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
      //JBook semantics don't support constructor with arg for exceptions
      //throw new RuntimeException("abc");
      throw new RuntimeException();
    } finally {
      System.out.println("finally");
      if (true) return 3;
    }
  }
}
