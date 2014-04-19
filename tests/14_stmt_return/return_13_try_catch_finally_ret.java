public class return_13_try_catch_finally_ret {

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
    } catch (RuntimeException e) {
      System.out.println(e.toString());
      return 2;
    } finally {
      System.out.println("finally");
      if (true) return 3;
    }
    System.out.println("unreachable");
    return 4;
  }
}
