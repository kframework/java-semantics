public class return_11_ret_ref_exact {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f() = " + f());
  }

  RuntimeException f() {
    return new RuntimeException("abc");
  }
}
