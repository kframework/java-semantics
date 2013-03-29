public class return_12_try_catch_ret_finally {

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
      //JBook semantics don't support constructor with arg for exceptions
      //if (true) throw new RuntimeException("re");
      if (true) throw new RuntimeException();
      System.out.println("unreachable");
    } catch (RuntimeException e) {
      System.out.println(e.toString());
      return 2;
    } finally {
      System.out.println("finally");
    }
    System.out.println("unreachable");
    return 4;
  }
}
