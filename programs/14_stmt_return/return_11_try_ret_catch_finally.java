public class return_11_try_ret_catch_finally {

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
      if (true) return 1;
      System.out.println("unreachable");
    } catch (RuntimeException e) {
      System.out.println(e.toString());
      throw e;
    } finally {
      System.out.println("finally");
    }
    System.out.println("unreachable");
    return 4;
  }
}
