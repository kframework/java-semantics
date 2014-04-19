public class return_17_ret_string {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f() = " + f());
  }

  String f() {
    return "abc";
  }
}
