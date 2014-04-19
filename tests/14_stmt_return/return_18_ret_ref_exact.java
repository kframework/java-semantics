public class return_18_ret_ref_exact {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f() = " + f().toString());
  }

  RuntimeException f() {
    return new RuntimeException();
    //JBook semantics don't support constructor with arg for exceptions
    //return new RuntimeException("abc");
  }
}
