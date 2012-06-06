public class return_12_try_catch_ret_finally_ret {

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
    } catch (RuntimeException e) {
      System.out.println(e.toString());
      return 2;
    } finally {
      System.out.println("finally");
      if (true) return 3;
    }
  }
}
